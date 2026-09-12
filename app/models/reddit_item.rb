class RedditItem < ApplicationRecord
  has_neighbors :embedding

  enum :item_type, { post: 0, comment: 1 }

  validates :reddit_id, presence: true, uniqueness: true
  validates :item_type, presence: true
  validates :posted_at, presence: true
end
