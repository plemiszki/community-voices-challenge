require "rails_helper"

RSpec.describe Embeddings::BatchEmbedder do
  let(:client) { instance_double(Embeddings::VoyageClient) }
  let(:embedding_a) { Array.new(1024) { 0.1 } }
  let(:embedding_b) { Array.new(1024) { 0.2 } }

  it "embeds each item's embedding_text in a single batched call" do
    post = create(:reddit_item, title: "Devlog", body: "Shipped a feature")
    comment = create(:reddit_item, :comment, post: post, body: "Nice!")

    expect(client).to receive(:embed)
      .with([ post.embedding_text, comment.embedding_text ], input_type: "document")
      .and_return([ embedding_a, embedding_b ])

    described_class.call([ post, comment ], client: client)

    expect(post.reload.embedding.to_a).to eq(embedding_a)
    expect(comment.reload.embedding.to_a).to eq(embedding_b)
  end

  it "sets embedded_at on each embedded item" do
    post = create(:reddit_item, embedded_at: nil)
    allow(client).to receive(:embed).and_return([ embedding_a ])

    described_class.call([ post ], client: client)

    expect(post.reload.embedded_at).to be_present
  end

  it "does nothing, and makes no API call, when given no items" do
    expect(client).not_to receive(:embed)

    described_class.call([], client: client)
  end
end
