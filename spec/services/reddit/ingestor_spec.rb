require "rails_helper"

RSpec.describe Reddit::Ingestor do
  let(:attributes) do
    {
      reddit_id: "t3_abc111",
      item_type: :post,
      parent_reddit_id: nil,
      title: "Devlog",
      body: "Body text",
      author: "dev_alice",
      score: 10,
      permalink: "https://www.reddit.com/r/gamedev/comments/abc111/",
      posted_at: 2.days.ago
    }
  end

  before do
    allow(Reddit::SeedLoader).to receive(:items).and_return([ attributes ])
    allow(Embeddings::BatchEmbedder).to receive(:call)
    allow(Embeddings::PcaReducer).to receive(:call)
  end

  it "creates a RedditItem for each item returned by SeedLoader" do
    expect { described_class.call }.to change(RedditItem, :count).by(1)

    expect(RedditItem.find_by(reddit_id: "t3_abc111").title).to eq("Devlog")
  end

  it "is idempotent: re-running does not create duplicates" do
    described_class.call

    expect { described_class.call }.not_to change(RedditItem, :count)
  end

  it "updates attributes on re-ingestion instead of erroring on the second run" do
    described_class.call
    allow(Reddit::SeedLoader).to receive(:items).and_return([ attributes.merge(score: 999) ])

    described_class.call

    expect(RedditItem.find_by(reddit_id: "t3_abc111").score).to eq(999)
  end

  it "hands not-yet-embedded items to the batch embedder" do
    described_class.call

    expect(Embeddings::BatchEmbedder).to have_received(:call) do |reddit_items|
      expect(reddit_items).to contain_exactly(RedditItem.find_by(reddit_id: "t3_abc111"))
    end
  end

  it "recomputes PCA over every embedded item, not just this run's new ones" do
    previously_embedded = create(:reddit_item, embedded_at: 1.day.ago)

    described_class.call

    expect(Embeddings::PcaReducer).to have_received(:call) do |reddit_items|
      expect(reddit_items).to include(previously_embedded)
    end
  end
end
