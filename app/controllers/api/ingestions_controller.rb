module Api
  class IngestionsController < ApplicationController
    def show
      render json: ingestion_status
    end

    def create
      Reddit::Ingestor.call

      render json: ingestion_status
    end

    private

    def ingestion_status
      {
        reddit_items_count: RedditItem.count,
        embedded_count: RedditItem.where.not(embedded_at: nil).count
      }
    end
  end
end
