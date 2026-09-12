require "rumale/decomposition/pca"

module Embeddings
  # Flattens RedditItem embeddings to 2D coordinates for the visualization,
  # via PCA's fixed-point (power iteration) solver — no external BLAS/LAPACK
  # dependency, unlike Rumale's "evd" solver.
  class PcaReducer
    COMPONENTS = 2
    RANDOM_SEED = 42
    MINIMUM_ITEMS = 2

    def self.call(reddit_items)
      new(reddit_items).call
    end

    def initialize(reddit_items)
      @reddit_items = reddit_items.to_a
    end

    def call
      return if reddit_items.size < MINIMUM_ITEMS

      coordinates = pca.fit_transform(matrix)
      reddit_items.each_with_index do |item, i|
        item.update_columns(x: coordinates[i, 0], y: coordinates[i, 1])
      end
    end

    private

    attr_reader :reddit_items

    def pca
      Rumale::Decomposition::PCA.new(n_components: COMPONENTS, solver: "fpt", random_seed: RANDOM_SEED)
    end

    def matrix
      Numo::DFloat[*reddit_items.map { |item| item.embedding.to_a }]
    end
  end
end
