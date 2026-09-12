require "rails_helper"

RSpec.describe "CommunityVoicesDocuments", type: :request do
  describe "POST /api/community_voices_document" do
    it "returns both the RAG and baseline documents" do
      allow(Rag::DocumentGenerator).to receive(:call).and_return("rag document")
      allow(Baseline::DocumentGenerator).to receive(:call).and_return("baseline document")

      post "/api/community_voices_document"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq("rag" => "rag document", "baseline" => "baseline document")
    end

    it "returns 422 with a clear message when nothing has been ingested" do
      allow(Rag::DocumentGenerator).to receive(:call)
        .and_raise(RedditItem::NotIngestedError, "No reddit_items found — run `rails reddit:ingest` first.")

      post "/api/community_voices_document"

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to include("rails reddit:ingest")
    end
  end
end
