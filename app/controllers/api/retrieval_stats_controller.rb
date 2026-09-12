module Api
  class RetrievalStatsController < ApplicationController
    RESULT_LIMIT = 20

    def index
      @reddit_items = RedditItem.where("retrieval_count > 0").order(retrieval_count: :desc).limit(RESULT_LIMIT)
    end
  end
end
