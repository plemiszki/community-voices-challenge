require "rails_helper"

RSpec.describe Reddit::SeedLoader do
  let(:directory) { Rails.root.join("spec/fixtures/reddit_seed_data") }

  subject(:items) { described_class.items(directory: directory) }

  it "normalizes every post in top.json" do
    posts = items.select { |item| item[:item_type] == :post }

    expect(posts.map { |post| post[:reddit_id] }).to contain_exactly("t3_abc111", "t3_xyz222")
  end

  it "maps post fields correctly" do
    post = items.find { |item| item[:reddit_id] == "t3_abc111" }

    expect(post).to include(
      item_type: :post,
      parent_reddit_id: nil,
      title: "Devlog: our combat system",
      body: "We rebuilt combat this week and it finally feels good.",
      author: "dev_alice",
      score: 120,
      permalink: "https://www.reddit.com/r/gamedev/comments/abc111/devlog_our_combat_system/"
    )
    expect(post[:posted_at]).to eq(Time.at(1893456000).utc)
  end

  it "keeps only the top 8 comments by score, dropping the 9th" do
    comments = items.select { |item| item[:item_type] == :comment }

    expect(comments.size).to eq(8)
    expect(comments.map { |comment| comment[:score] }).to eq([ 50, 40, 35, 30, 25, 20, 15, 10 ])
    expect(comments.map { |comment| comment[:reddit_id] }).not_to include("t1_c9_lowest")
  end

  it "excludes deleted comments regardless of score" do
    comments = items.select { |item| item[:item_type] == :comment }

    expect(comments.map { |comment| comment[:reddit_id] }).not_to include("t1_deleted")
  end

  it "excludes replies that are not top-level" do
    comments = items.select { |item| item[:item_type] == :comment }

    expect(comments.map { |comment| comment[:reddit_id] }).not_to include("t1_reply")
  end

  it "sets a comment's parent_reddit_id to the post's fullname and leaves title blank" do
    comment = items.find { |item| item[:reddit_id] == "t1_c1" }

    expect(comment[:parent_reddit_id]).to eq("t3_abc111")
    expect(comment[:title]).to be_nil
  end

  it "raises when a comments file's post id does not match its filename" do
    Dir.mktmpdir do |dir|
      tmp = Pathname.new(dir)
      FileUtils.cp(directory.join("top.json"), tmp.join("top.json"))
      FileUtils.mkdir_p(tmp.join("comments"))

      mismatched = JSON.parse(File.read(directory.join("comments/abc111.json")))
      mismatched[0]["data"]["children"][0]["data"]["id"] = "wrong_id"
      File.write(tmp.join("comments/abc111.json"), mismatched.to_json)

      expect { described_class.items(directory: tmp) }
        .to raise_error(/contains post wrong_id, expected abc111/)
    end
  end
end
