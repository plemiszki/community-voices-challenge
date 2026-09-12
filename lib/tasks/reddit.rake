namespace :reddit do
  desc "Ingest the committed r/gamedev seed data into reddit_items"
  task ingest: :environment do
    Reddit::Ingestor.call

    puts "Ingested #{RedditItem.count} reddit_items " \
         "(#{RedditItem.post.count} posts, #{RedditItem.comment.count} comments)."
  end
end
