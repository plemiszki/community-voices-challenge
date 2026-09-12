require "rails_helper"

RSpec.describe Rag::DocumentGenerator do
  let(:retriever) { class_double(Rag::Retriever) }
  let(:claude_client) { instance_double(Claude::Client) }

  let(:recent_post) do
    create(:reddit_item, title: "Devlog update", body: "Shipped multiplayer.",
      permalink: "https://www.reddit.com/r/gamedev/comments/recent/")
  end

  let(:prospective_comment) do
    parent = create(:reddit_item, title: "Launch plans thread")
    create(:reddit_item, :comment, post: parent, body: "We're launching next Tuesday.",
      permalink: "https://www.reddit.com/r/gamedev/comments/launch/x/c1/")
  end

  before do
    create(:reddit_item, posted_at: Time.zone.parse("2026-09-06 10:00:00"), embedded_at: Time.current)
    create(:reddit_item, posted_at: Time.zone.parse("2026-09-12 15:00:00"), embedded_at: Time.current)
    allow(claude_client).to receive(:generate).and_return("generated document body")
    stub_retrieval(recent: [ recent_post ], prospective: [ prospective_comment ])
  end

  it "raises NotIngestedError without calling Claude when nothing has been ingested" do
    RedditItem.delete_all

    expect { generate }.to raise_error(RedditItem::NotIngestedError)
    expect(claude_client).not_to have_received(:generate)
  end

  it "raises NotEmbeddedError without calling Claude when items exist but none are embedded" do
    RedditItem.delete_all
    create(:reddit_item, embedded_at: nil)

    expect { generate }.to raise_error(RedditItem::NotEmbeddedError)
    expect(claude_client).not_to have_received(:generate)
  end

  def stub_retrieval(recent:, prospective:)
    allow(retriever).to receive(:call)
      .with(query: Rag::DocumentGenerator::RETROSPECTIVE_QUERY, k: Rag::Retriever::DEFAULT_K)
      .and_return(RedditItem.where(id: recent.map(&:id)))
    allow(retriever).to receive(:call)
      .with(query: Rag::DocumentGenerator::PROSPECTIVE_QUERY, k: Rag::Retriever::DEFAULT_K)
      .and_return(RedditItem.where(id: prospective.map(&:id)))
  end

  def generate
    described_class.call(retriever: retriever, claude_client: claude_client)
  end

  it "returns Claude's generated text followed by a Sources section" do
    result = generate

    expect(result).to start_with("generated document body")
    expect(result).to include("## Sources")
  end

  it "cites the retrieved items' real permalinks, numbered in order" do
    result = generate

    expect(result).to include("[1] #{recent_post.permalink}")
    expect(result).to include("[2] #{prospective_comment.permalink}")
  end

  it "sends each item's embedding_text as a numbered excerpt to Claude" do
    generate

    expect(claude_client).to have_received(:generate).with(
      system: anything,
      user: a_string_including("[1] #{recent_post.embedding_text}")
        .and(a_string_including("[2] #{prospective_comment.embedding_text}"))
    )
  end

  it "anchors the system prompt to the ingested date range" do
    generate

    expect(claude_client).to have_received(:generate).with(
      system: a_string_including("September 6, 2026").and(a_string_including("September 12, 2026")),
      user: anything
    )
  end

  it "gives an item retrieved by both queries one consistent citation number, not two" do
    shared_item = create(:reddit_item, title: "Popular thread", body: "Everyone's talking about this.")
    stub_retrieval(recent: [ shared_item ], prospective: [ shared_item ])

    result = generate

    expect(claude_client).to have_received(:generate).with(
      system: anything,
      user: a_string_including("[1] #{shared_item.embedding_text}")
        .and(satisfy { |text| !text.include?("[2]") })
    )
    expect(result.scan(/^\[\d+\]/).size).to eq(1)
  end
end
