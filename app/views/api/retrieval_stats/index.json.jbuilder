json.array! @reddit_items do |item|
  json.id item.id
  json.item_type item.item_type
  json.snippet (item.title || item.body).to_s.truncate(80)
  json.permalink item.permalink
  json.retrieval_count item.retrieval_count
end
