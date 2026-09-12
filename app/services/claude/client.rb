module Claude
  # Thin wrapper around the official Anthropic SDK, centralizing the model
  # choice and extracting the plain text response.
  class Client
    MODEL = "claude-sonnet-5"
    MAX_TOKENS = 16_000

    def generate(system:, user:)
      response = client.messages.create(
        model: MODEL,
        max_tokens: MAX_TOKENS,
        system: system,
        messages: [ { role: "user", content: user } ]
      )

      text_from(response)
    end

    private

    def client
      @client ||= Anthropic::Client.new
    end

    def text_from(response)
      response.content
        .select { |block| block.type == :text }
        .map(&:text)
        .join
    end
  end
end
