module Embeddings
  # Thin HTTP client for Voyage AI's embeddings API. No official Ruby SDK
  # exists, so this talks to the REST endpoint directly via Faraday.
  class VoyageClient
    BASE_URL = "https://api.voyageai.com"
    MODEL = "voyage-4-lite"

    def embed(texts, input_type:)
      response = connection.post("/v1/embeddings") do |request|
        request.headers["Content-Type"] = "application/json"
        request.body = { input: texts, model: MODEL, input_type: input_type }.to_json
      end

      unless response.success?
        raise "Voyage embeddings request failed (#{response.status}): #{response.body}"
      end

      embeddings_in_input_order(response.body)
    end

    private

    def connection
      @connection ||= Faraday.new(url: BASE_URL) do |faraday|
        faraday.headers["Authorization"] = "Bearer #{ENV.fetch('VOYAGE_API_KEY')}"
        faraday.adapter Faraday.default_adapter
      end
    end

    def embeddings_in_input_order(response_body)
      JSON.parse(response_body)
        .fetch("data")
        .sort_by { |item| item["index"] }
        .map { |item| item["embedding"] }
    end
  end
end
