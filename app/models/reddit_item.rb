class RedditItem < ApplicationRecord
  has_neighbors :embedding

  enum :item_type, { post: 0, comment: 1 }

  belongs_to :post, class_name: "RedditItem", foreign_key: :parent_reddit_id,
    primary_key: :reddit_id, inverse_of: :comments, optional: true
  has_many :comments, class_name: "RedditItem", foreign_key: :parent_reddit_id,
    primary_key: :reddit_id, inverse_of: :post

  validates :reddit_id, presence: true, uniqueness: true
  validates :item_type, presence: true
  validates :posted_at, presence: true
end
