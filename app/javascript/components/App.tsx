import { useEffect, useState } from "react"
import { fetchIngestionStatus } from "../api/client"
import type { IngestionResult } from "../types/api"
import IngestionPanel from "./IngestionPanel"
import DocumentComparison from "./DocumentComparison"
import EmbeddingScatterPlot from "./EmbeddingScatterPlot"
import RetrievalStatsTable from "./RetrievalStatsTable"

export default function App() {
  const [status, setStatus] = useState<IngestionResult | null>(null)
  const [checking, setChecking] = useState(true)
  const [generationCount, setGenerationCount] = useState(0)

  useEffect(() => {
    fetchIngestionStatus()
      .then(setStatus)
      .catch(() => setStatus(null))
      .finally(() => setChecking(false))
  }, [])

  const ingested = (status?.embedded_count ?? 0) > 0

  return (
    <div className="app">
      <header className="app-header">
        <h1>Community Voices: r/gamedev</h1>
        <p>RAG-powered vs. baseline document generation, backed by real ingested Reddit data.</p>
      </header>
      <section className="panel app-intro">
        <p>
          This app builds a "Community Voices Document" for r/gamedev using Retrieval-Augmented
          Generation (RAG): real posts and comments are ingested, embedded, and retrieved by semantic
          similarity to ground the generated summary and predictions in actual community discussion. A
          baseline document, generated with no retrieved context, is shown alongside it for comparison.
          The sections below let you run ingestion, generate both documents, and explore the underlying
          embedding space and retrieval activity.
        </p>
      </section>
      <IngestionPanel status={status} checking={checking} onStatusChange={setStatus} />
      <DocumentComparison
        ingested={ingested}
        onGenerated={() => setGenerationCount((count) => count + 1)}
      />
      <EmbeddingScatterPlot ingested={ingested} refreshKey={generationCount} />
      <RetrievalStatsTable ingested={ingested} refreshKey={generationCount} />
    </div>
  )
}
