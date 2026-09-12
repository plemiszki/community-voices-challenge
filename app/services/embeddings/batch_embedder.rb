module Embeddings
  # Embeds a collection of RedditItems in a single batched Voyage API call
  # and saves the resulting vectors back onto each record.
  class BatchEmbedder
    def self.call(reddit_items, client: VoyageClient.new)
      new(reddit_items, client).call
    end

    def initialize(reddit_items, client)
      @reddit_items = reddit_items.to_a
      @client = client
    end

    def call
      return if reddit_items.empty?

      embeddings = client.embed(reddit_items.map(&:embedding_text), input_type: "document")

      reddit_items.zip(embeddings).each do |reddit_item, embedding|
        reddit_item.update!(embedding: embedding, embedded_at: Time.current)
      end
    end

    private

    attr_reader :reddit_items, :client
  end
end
