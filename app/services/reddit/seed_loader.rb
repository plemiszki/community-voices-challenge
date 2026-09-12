module Reddit
  # Parses the committed raw Reddit JSON under db/seed_data and normalizes it
  # into plain attribute hashes shaped like RedditItem columns.
  class SeedLoader
    TOP_LEVEL_COMMENTS_PER_POST = 8
    DELETED_BODIES = [ "[deleted]", "[removed]" ].freeze

    def self.items(directory: Rails.root.join("db/seed_data"))
      new(directory).items
    end

    def initialize(directory)
      @directory = directory
    end

    def items
      posts + comments
    end

    private

    attr_reader :directory

    def posts
      raw_posts.map { |post_data| normalize_post(post_data) }
    end

    def raw_posts
      listing = JSON.parse(File.read(directory.join("top.json")))
      listing.dig("data", "children").map { |child| child["data"] }
    end

    def normalize_post(post_data)
      {
        reddit_id: post_data["name"],
        item_type: :post,
        parent_reddit_id: nil,
        title: post_data["title"],
        body: post_data["selftext"],
        author: post_data["author"],
        score: post_data["score"],
        permalink: full_permalink(post_data["permalink"]),
        posted_at: to_time(post_data["created_utc"])
      }
    end

    def comments
      comment_files.flat_map { |file| normalize_comments_file(file) }
    end

    def comment_files
      Dir.glob(directory.join("comments", "*.json")).sort
    end

    def normalize_comments_file(file)
      post_listing, comments_listing = JSON.parse(File.read(file))
      post_data = post_listing.dig("data", "children", 0, "data")
      verify_post_id_matches_filename!(post_data["id"], file)

      link_id = "t3_#{post_data['id']}"
      children = comments_listing.dig("data", "children")

      top_level_comments(children, link_id).map { |comment_data| normalize_comment(comment_data, link_id) }
    end

    def top_level_comments(children, link_id)
      children
        .select { |child| child["kind"] == "t1" }
        .map { |child| child["data"] }
        .select { |data| data["parent_id"] == link_id }
        .reject { |data| DELETED_BODIES.include?(data["body"]) }
        .sort_by { |data| -data["score"] }
        .first(TOP_LEVEL_COMMENTS_PER_POST)
    end

    def normalize_comment(comment_data, link_id)
      {
        reddit_id: comment_data["name"],
        item_type: :comment,
        parent_reddit_id: link_id,
        title: nil,
        body: comment_data["body"],
        author: comment_data["author"],
        score: comment_data["score"],
        permalink: full_permalink(comment_data["permalink"]),
        posted_at: to_time(comment_data["created_utc"])
      }
    end

    def verify_post_id_matches_filename!(post_id, file)
      expected_id = File.basename(file, ".json")
      return if post_id == expected_id

      raise "Comments file #{file} contains post #{post_id}, expected #{expected_id}"
    end

    def full_permalink(relative_permalink)
      "https://www.reddit.com#{relative_permalink}"
    end

    def to_time(created_utc)
      Time.at(created_utc.to_f).utc
    end
  end
end
