require "rails_helper"

RSpec.describe "Ingestions", type: :request do
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
