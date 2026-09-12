require "rails_helper"

RSpec.describe RedditItem, type: :model do
  it "is valid with a complete set of attributes" do
    expect(build(:reddit_item)).to be_valid
  end

  it "is valid as a comment" do
    expect(build(:reddit_item, :comment)).to be_valid
  end

  it "requires a reddit_id" do
    reddit_item = build(:reddit_item, reddit_id: nil)

    expect(reddit_item).not_to be_valid
    expect(reddit_item.errors[:reddit_id]).to be_present
  end

  it "requires reddit_id to be unique" do
    create(:reddit_item, reddit_id: "t3_duplicate")
    duplicate = build(:reddit_item, reddit_id: "t3_duplicate")

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:reddit_id]).to be_present
  end

  it "requires posted_at" do
    reddit_item = build(:reddit_item, posted_at: nil)

    expect(reddit_item).not_to be_valid
    expect(reddit_item.errors[:posted_at]).to be_present
  end

  it "defaults retrieval_count to zero" do
    expect(create(:reddit_item).retrieval_count).to eq(0)
  end

  it "exposes item_type as an enum" do
    expect(build(:reddit_item, :comment)).to be_comment
  end
end
