module Api
  class CommunityVoicesDocumentsController < ApplicationController
    def create
      render json: {
        rag: Rag::DocumentGenerator.call,
        baseline: Baseline::DocumentGenerator.call
      }
    end
  end
end
