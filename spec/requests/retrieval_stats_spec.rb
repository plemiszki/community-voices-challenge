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
      create_list(:reddit_item, Api::RetrievalStatsController::RESULT_LIMIT + 5, retrieval_count: 1)

      get "/api/retrieval_stats", as: :json

      expect(response.parsed_body.size).to eq(Api::RetrievalStatsController::RESULT_LIMIT)
    end

    it "falls back to a body excerpt for comments, which have no title" do
      comment = create(:reddit_item, :comment, body: "This is a great point about the topic.", retrieval_count: 1)

      get "/api/retrieval_stats", as: :json

      snippet = response.parsed_body.find { |item| item["id"] == comment.id }["snippet"]
      expect(snippet).to eq("This is a great point about the topic.")
    end

    it "excludes items that have never been retrieved" do
      create(:reddit_item, retrieval_count: 0)

      get "/api/retrieval_stats", as: :json

      expect(response.parsed_body).to be_empty
    end
  end
end
