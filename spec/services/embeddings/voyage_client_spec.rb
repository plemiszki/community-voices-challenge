require "rails_helper"

RSpec.describe Embeddings::VoyageClient do
  subject(:client) { described_class.new }

  before { ENV["VOYAGE_API_KEY"] = "test-key" }
  after { ENV.delete("VOYAGE_API_KEY") }

  describe "#embed" do
    it "sends the texts and returns embeddings in input order" do
      stub_request(:post, "https://api.voyageai.com/v1/embeddings")
        .with(
          headers: { "Authorization" => "Bearer test-key", "Content-Type" => "application/json" },
          body: { input: [ "dog", "cat" ], model: "voyage-4-lite", input_type: "document" }.to_json
        )
        .to_return(
          status: 200,
          body: {
            object: "list",
            data: [
              { object: "embedding", embedding: [ 0.1, 0.2 ], index: 0 },
              { object: "embedding", embedding: [ 0.3, 0.4 ], index: 1 }
            ],
            model: "voyage-4-lite",
            usage: { total_tokens: 4 }
          }.to_json
        )

      result = client.embed([ "dog", "cat" ], input_type: "document")

      expect(result).to eq([ [ 0.1, 0.2 ], [ 0.3, 0.4 ] ])
    end

    it "reorders embeddings by index, regardless of response order" do
      stub_request(:post, "https://api.voyageai.com/v1/embeddings").to_return(
        status: 200,
        body: {
          data: [
            { embedding: [ 0.3, 0.4 ], index: 1 },
            { embedding: [ 0.1, 0.2 ], index: 0 }
          ]
        }.to_json
      )

      result = client.embed([ "dog", "cat" ], input_type: "document")

      expect(result).to eq([ [ 0.1, 0.2 ], [ 0.3, 0.4 ] ])
    end

    it "raises a descriptive error when the request fails" do
      stub_request(:post, "https://api.voyageai.com/v1/embeddings")
        .to_return(status: 401, body: { detail: "Invalid API key" }.to_json)

      expect { client.embed([ "dog" ], input_type: "document") }
        .to raise_error(/Voyage embeddings request failed \(401\)/)
    end
  end
end
