module Api
  class IngestionsController < ApplicationController
    def create
      Reddit::Ingestor.call

      render json: {
        reddit_items_count: RedditItem.count,
        embedded_count: RedditItem.where.not(embedded_at: nil).count
      }
    end
  end
end
