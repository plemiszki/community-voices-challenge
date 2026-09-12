require "rails_helper"

RSpec.describe "Embeddings", type: :request do
  describe "GET /api/embeddings/visualization" do
    it "returns items that have PCA coordinates" do
      plotted = create(:reddit_item, title: "Devlog", x: 0.1, y: -0.2, retrieval_count: 3)

      get "/api/embeddings/visualization", as: :json

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body.size).to eq(1)
      expect(body.first).to include(
        "id" => plotted.id,
        "x" => 0.1,
        "y" => -0.2,
        "retrieval_count" => 3,
        "snippet" => "Devlog"
      )
    end

    it "excludes items that have not been through PCA yet" do
      create(:reddit_item, x: nil, y: nil)

      get "/api/embeddings/visualization", as: :json

      expect(response.parsed_body).to be_empty
    end
  end
end
