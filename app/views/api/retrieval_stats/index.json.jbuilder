json.array! @reddit_items do |item|
  json.id item.id
  json.item_type item.item_type
  json.title item.title
  json.permalink item.permalink
  json.retrieval_count item.retrieval_count
end
