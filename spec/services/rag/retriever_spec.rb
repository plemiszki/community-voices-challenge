require "rails_helper"

RSpec.describe Rag::Retriever do
  let(:client) { instance_double(Embeddings::VoyageClient) }
  let(:query) { "what happened this week?" }
  let(:query_vector) { basis_vector(0) }

  def basis_vector(index, magnitude: 1.0)
    Array.new(1024, 0.0).tap { |vector| vector[index] = magnitude }
  end

  before do
    allow(client).to receive(:embed).with([ query ], input_type: "query").and_return([ query_vector ])
  end

  it "returns items ordered by cosine similarity to the embedded query, limited to k" do
    near = create(:reddit_item, embedding: basis_vector(0).tap { |v| v[1] = 0.1 })
    orthogonal = create(:reddit_item, embedding: basis_vector(1))
    opposite = create(:reddit_item, embedding: basis_vector(0, magnitude: -1.0))

    results = described_class.call(query: query, k: 2, client: client)

    expect(results.to_a).to eq([ near, orthogonal ])
    expect(results).not_to include(opposite)
  end

  it "increments retrieval_count only on the items actually returned" do
    near = create(:reddit_item, embedding: basis_vector(0))
    far = create(:reddit_item, embedding: basis_vector(1))

    described_class.call(query: query, k: 1, client: client)

    expect(near.reload.retrieval_count).to eq(1)
    expect(far.reload.retrieval_count).to eq(0)
  end

  it "embeds the query with input_type: query rather than document" do
    create(:reddit_item, embedding: basis_vector(0))

    described_class.call(query: query, k: 1, client: client)

    expect(client).to have_received(:embed).with([ query ], input_type: "query")
  end
end
