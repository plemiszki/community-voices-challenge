module Api
  class RetrievalStatsController < ApplicationController
    RESULT_LIMIT = 20

    def index
      @reddit_items = RedditItem.order(retrieval_count: :desc).limit(RESULT_LIMIT)
    end
  end
end
