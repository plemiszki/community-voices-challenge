module Api
  class EmbeddingsController < ApplicationController
    def visualization
      @reddit_items = RedditItem.where.not(x: nil)
    end
  end
end
