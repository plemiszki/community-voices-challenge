require "rails_helper"

RSpec.describe Claude::Client do
  subject(:client) { described_class.new }

  before { ENV["ANTHROPIC_API_KEY"] = "test-key" }
  after { ENV.delete("ANTHROPIC_API_KEY") }

  describe "#generate" do
    it "sends the system and user prompts and returns the response text" do
      stub_request(:post, "https://api.anthropic.com/v1/messages")
        .with(
          headers: { "X-Api-Key" => "test-key" },
          body: hash_including(
            "model" => "claude-sonnet-5",
            "system" => "You are a helpful assistant.",
            "messages" => [ { "role" => "user", "content" => "Say hello." } ]
          )
        )
        .to_return(
          status: 200,
          headers: { "Content-Type" => "application/json" },
          body: {
            id: "msg_123",
            type: "message",
            role: "assistant",
            model: "claude-sonnet-5",
            content: [ { type: "text", text: "Hello there!" } ],
            stop_reason: "end_turn",
            usage: { input_tokens: 10, output_tokens: 5 }
          }.to_json
        )

      result = client.generate(system: "You are a helpful assistant.", user: "Say hello.")

      expect(result).to eq("Hello there!")
    end

    it "joins multiple text blocks and ignores non-text blocks" do
      stub_request(:post, "https://api.anthropic.com/v1/messages").to_return(
        status: 200,
        headers: { "Content-Type" => "application/json" },
        body: {
          id: "msg_456",
          type: "message",
          role: "assistant",
          model: "claude-sonnet-5",
          content: [
            { type: "tool_use", id: "toolu_1", name: "irrelevant_tool", input: {} },
            { type: "text", text: "Part one. " },
            { type: "text", text: "Part two." }
          ],
          stop_reason: "end_turn",
          usage: { input_tokens: 10, output_tokens: 5 }
        }.to_json
      )

      result = client.generate(system: "sys", user: "hi")

      expect(result).to eq("Part one. Part two.")
    end
  end
end
