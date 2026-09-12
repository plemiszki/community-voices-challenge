export type ItemType = "post" | "comment"

export interface IngestionResult {
  reddit_items_count: number
  embedded_count: number
}

export interface CommunityVoicesDocuments {
  rag: string
  baseline: string
}

export interface EmbeddingPoint {
  id: number
  x: number
  y: number
  item_type: ItemType
  retrieval_count: number
  snippet: string
}

export interface RetrievalStatItem {
  id: number
  item_type: ItemType
  snippet: string
  permalink: string
  retrieval_count: number
}
