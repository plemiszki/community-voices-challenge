import type {
  CommunityVoicesDocuments,
  EmbeddingPoint,
  IngestionResult,
  RetrievalStatItem,
} from "../types/api"

function csrfToken(): string {
  const meta = document.querySelector('meta[name="csrf-token"]')
  return meta?.getAttribute("content") ?? ""
}

async function getJson<T>(url: string): Promise<T> {
  const response = await fetch(url, { headers: { Accept: "application/json" } })
  if (!response.ok) {
    throw new Error(`Request to ${url} failed with status ${response.status}`)
  }
  return response.json()
}

async function postJson<T>(url: string): Promise<T> {
  const response = await fetch(url, {
    method: "POST",
    headers: { Accept: "application/json", "X-CSRF-Token": csrfToken() },
  })
  const body = await response.json()
  if (!response.ok) {
    throw new Error(body.error ?? `Request to ${url} failed with status ${response.status}`)
  }
  return body
}

export function fetchIngestionStatus(): Promise<IngestionResult> {
  return getJson("/api/ingestion")
}

export function runIngestion(): Promise<IngestionResult> {
  return postJson("/api/ingestion")
}

export function generateDocuments(): Promise<CommunityVoicesDocuments> {
  return postJson("/api/community_voices_document")
}

export function fetchEmbeddingsVisualization(): Promise<EmbeddingPoint[]> {
  return getJson("/api/embeddings/visualization")
}

export function fetchRetrievalStats(): Promise<RetrievalStatItem[]> {
  return getJson("/api/retrieval_stats")
}
