require "rails_helper"

RSpec.describe Embeddings::PcaReducer do
  def vector(index, magnitude: 1.0)
    Array.new(1024, 0.0).tap { |v| v[index] = magnitude }
  end

  it "writes x and y coordinates for each item" do
    items = [
      create(:reddit_item, embedding: vector(0)),
      create(:reddit_item, embedding: vector(0, magnitude: 0.9)),
      create(:reddit_item, embedding: vector(500))
    ]

    described_class.call(items)

    items.each(&:reload)
    expect(items).to all(have_attributes(x: be_present, y: be_present))
  end

  it "places similar items closer together than dissimilar ones" do
    similar_a = create(:reddit_item, embedding: vector(0))
    similar_b = create(:reddit_item, embedding: vector(0, magnitude: 0.95))
    different = create(:reddit_item, embedding: vector(500))

    described_class.call([ similar_a, similar_b, different ])
    [ similar_a, similar_b, different ].each(&:reload)

    distance = ->(a, b) { Math.sqrt(((a.x - b.x)**2) + ((a.y - b.y)**2)) }

    expect(distance.call(similar_a, similar_b)).to be < distance.call(similar_a, different)
  end

  it "does nothing when fewer than 2 items are given" do
    item = create(:reddit_item, embedding: vector(0))

    described_class.call([ item ])

    expect(item.reload.x).to be_nil
  end

  it "does not touch updated_at, since this is a recomputed derived value" do
    a = create(:reddit_item, embedding: vector(0))
    b = create(:reddit_item, embedding: vector(1))
    original_updated_at = a.updated_at

    described_class.call([ a, b ])

    expect(a.reload.updated_at).to eq(original_updated_at)
  end
end
