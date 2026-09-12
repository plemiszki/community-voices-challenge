module Rag
  # Embeds a query and returns the k most semantically similar RedditItems,
  # tracking how often each item gets retrieved along the way.
  class Retriever
    DEFAULT_K = 15

    def self.call(query:, k: DEFAULT_K, client: Embeddings::VoyageClient.new)
      new(client).call(query: query, k: k)
    end

    def initialize(client)
      @client = client
    end

    def call(query:, k:)
      neighbors = RedditItem.nearest_neighbors(:embedding, query_vector(query), distance: "cosine").limit(k)
      neighbors.each { |item| item.increment!(:retrieval_count) }
      neighbors
    end

    private

    attr_reader :client

    def query_vector(query)
      client.embed([ query ], input_type: "query").first
    end
  end
end
