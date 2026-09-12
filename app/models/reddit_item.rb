class RedditItem < ApplicationRecord
  EMBEDDING_TEXT_MAX_LENGTH = 1500

  has_neighbors :embedding

  enum :item_type, { post: 0, comment: 1 }

  belongs_to :post, class_name: "RedditItem", foreign_key: :parent_reddit_id,
    primary_key: :reddit_id, inverse_of: :comments, optional: true
  has_many :comments, class_name: "RedditItem", foreign_key: :parent_reddit_id,
    primary_key: :reddit_id, inverse_of: :post

  validates :reddit_id, presence: true, uniqueness: true
  validates :item_type, presence: true
  validates :posted_at, presence: true

  # The compact text representation used both for the Voyage embedding input
  # and for RAG prompt context snippets. A bare comment body is nearly
  # meaningless on its own, so comments are anchored to their parent post's
  # title.
  def embedding_text
    full_text.truncate(EMBEDDING_TEXT_MAX_LENGTH, omission: "")
  end

  private

  def full_text
    return "#{title}\n\n#{body}".strip if post?

    "Context: #{post.title}\n\nComment: #{body}"
  end
end
