class CreateRedditItems < ActiveRecord::Migration[8.1]
  def change
    create_table :reddit_items do |t|
      t.string :reddit_id, null: false
      t.integer :item_type, null: false
      t.string :parent_reddit_id
      t.string :title
      t.text :body
      t.string :author
      t.integer :score, null: false, default: 0
      t.string :permalink
      t.datetime :posted_at, null: false
      t.vector :embedding, limit: 1024
      t.datetime :embedded_at
      t.float :x
      t.float :y
      t.integer :retrieval_count, null: false, default: 0

      t.timestamps
    end

    add_index :reddit_items, :reddit_id, unique: true
  end
end
