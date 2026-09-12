require "rails_helper"

RSpec.describe "RetrievalStats", type: :request do
  describe "GET /api/retrieval_stats" do
    it "returns items ordered by retrieval_count, descending" do
      low = create(:reddit_item, retrieval_count: 1)
      high = create(:reddit_item, retrieval_count: 10)

      get "/api/retrieval_stats", as: :json

      expect(response).to have_http_status(:ok)
      ids = response.parsed_body.map { |item| item["id"] }
      expect(ids).to eq([ high.id, low.id ])
    end

    it "limits results to Api::RetrievalStatsController::RESULT_LIMIT" do
      create_list(:reddit_item, Api::RetrievalStatsController::RESULT_LIMIT + 5)

      get "/api/retrieval_stats", as: :json

      expect(response.parsed_body.size).to eq(Api::RetrievalStatsController::RESULT_LIMIT)
    end
  end
end
