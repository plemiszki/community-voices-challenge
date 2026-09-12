require "rails_helper"

RSpec.describe "Ingestions", type: :request do
  describe "GET /api/ingestion" do
    it "reports current item counts without running ingestion" do
      create(:reddit_item, embedded_at: Time.current)
      create(:reddit_item, embedded_at: nil)

      expect(Reddit::Ingestor).not_to receive(:call)
      get "/api/ingestion", as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("reddit_items_count" => 2, "embedded_count" => 1)
    end

    it "reports zero counts before anything has been ingested" do
      get "/api/ingestion", as: :json

      expect(response.parsed_body).to eq("reddit_items_count" => 0, "embedded_count" => 0)
    end
  end

  describe "POST /api/ingestion" do
    it "runs the ingestion pipeline and returns item counts" do
      allow(Reddit::Ingestor).to receive(:call) do
        create(:reddit_item, embedded_at: Time.current)
        create(:reddit_item, embedded_at: nil)
      end

      post "/api/ingestion"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("reddit_items_count" => 2, "embedded_count" => 1)
    end
  end
end
