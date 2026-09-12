module Reddit
  # Upserts SeedLoader's normalized items into reddit_items. Idempotent on
  # reddit_id, so re-running (e.g. after collecting a fresh week's data) is safe.
  class Ingestor
    def self.call
      new.call
    end

    def call
      SeedLoader.items.each { |attributes| upsert(attributes) }
      Embeddings::BatchEmbedder.call(RedditItem.where(embedded_at: nil))

      # Recomputed over every embedded item, not just the new ones — PCA is a
      # global fit, so adding items can shift what "most variance" even means.
      Embeddings::PcaReducer.call(RedditItem.where.not(embedded_at: nil))
    end

    private

    def upsert(attributes)
      RedditItem
        .find_or_initialize_by(reddit_id: attributes[:reddit_id])
        .update!(attributes)
    end
  end
end
