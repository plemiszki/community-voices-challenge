require "rails_helper"

RSpec.describe Baseline::DocumentGenerator do
  let(:claude_client) { instance_double(Claude::Client) }

  before do
    allow(claude_client).to receive(:generate).and_return("generated document")
    create(:reddit_item, posted_at: Time.zone.parse("2026-09-06 10:00:00"))
    create(:reddit_item, posted_at: Time.zone.parse("2026-09-12 15:00:00"))
  end

  it "returns Claude's generated text" do
    expect(described_class.call(claude_client: claude_client)).to eq("generated document")
  end

  it "tells Claude it has no retrieved data and must not invent specifics" do
    described_class.call(claude_client: claude_client)

    expect(claude_client).to have_received(:generate).with(
      system: a_string_including("no access to live data")
        .and(a_string_including("no data was retrieved"))
        .and(a_string_including("Do not fabricate specific post titles")),
      user: anything
    )
  end

  it "anchors the prompt to the actual ingested date range, not today's date" do
    described_class.call(claude_client: claude_client)

    expect(claude_client).to have_received(:generate).with(
      system: anything,
      user: a_string_including("r/gamedev")
        .and(a_string_including("September 6, 2026"))
        .and(a_string_including("September 12, 2026"))
    )
  end
end
