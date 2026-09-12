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

  it "links a comment to its parent post" do
    comment = create(:reddit_item, :comment)

    expect(comment.post).to eq(RedditItem.find_by(reddit_id: comment.parent_reddit_id))
  end

  it "lists a post's comments" do
    post = create(:reddit_item)
    comment = create(:reddit_item, :comment, post: post)

    expect(post.comments).to contain_exactly(comment)
  end

  it "has no post for a top-level post" do
    expect(create(:reddit_item).post).to be_nil
  end

  describe "#embedding_text" do
    it "combines a post's title and body" do
      post = build(:reddit_item, title: "Devlog update", body: "We shipped a new feature.")

      expect(post.embedding_text).to eq("Devlog update\n\nWe shipped a new feature.")
    end

    it "falls back to just the title when a post has no body" do
      post = build(:reddit_item, title: "Screenshot Saturday", body: "")

      expect(post.embedding_text).to eq("Screenshot Saturday")
    end

    it "anchors a comment to its parent post's title" do
      parent = build(:reddit_item, title: "Devlog update")
      comment = build(:reddit_item, :comment, post: parent, body: "Great progress!")

      expect(comment.embedding_text).to eq("Context: Devlog update\n\nComment: Great progress!")
    end

    it "truncates long text to EMBEDDING_TEXT_MAX_LENGTH" do
      post = build(:reddit_item, title: "Long devlog", body: "a" * 2000)

      expect(post.embedding_text.length).to eq(RedditItem::EMBEDDING_TEXT_MAX_LENGTH)
    end
  end
end
