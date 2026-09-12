json.array! @reddit_items do |item|
  json.id item.id
  json.x item.x
  json.y item.y
  json.item_type item.item_type
  json.retrieval_count item.retrieval_count
  json.snippet (item.title || item.body).to_s.truncate(80)
end
