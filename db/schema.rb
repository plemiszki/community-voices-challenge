# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_12_033512) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "reddit_items", force: :cascade do |t|
    t.string "author"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "embedded_at"
    t.vector "embedding", limit: 1024
    t.integer "item_type", null: false
    t.string "parent_reddit_id"
    t.string "permalink"
    t.datetime "posted_at", null: false
    t.string "reddit_id", null: false
    t.integer "retrieval_count", default: 0, null: false
    t.integer "score", default: 0, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.float "x"
    t.float "y"
    t.index ["reddit_id"], name: "index_reddit_items_on_reddit_id", unique: true
  end
end
