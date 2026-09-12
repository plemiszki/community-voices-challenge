import { useState } from "react";
import { runIngestion } from "../api/client";
import type { IngestionResult } from "../types/api";

interface Props {
  status: IngestionResult | null;
  checking: boolean;
  onStatusChange: (status: IngestionResult) => void;
}

export default function IngestionPanel({ status, checking, onStatusChange }: Props) {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleClick() {
    setLoading(true);
    setError(null);
    try {
      onStatusChange(await runIngestion());
    } catch (err) {
      setError(err instanceof Error ? err.message : "Ingestion failed");
    } finally {
      setLoading(false);
    }
  }

  const ingested = (status?.embedded_count ?? 0) > 0;

  return (
    <section className="panel">
      <h2>
        Step 1 - Ingestion
        {ingested && (
          <span className="status-check" aria-label="Ingested">
            ✓
          </span>
        )}
      </h2>
      {checking ? (
        <p className="instructions">Checking ingestion status…</p>
      ) : ingested ? (
        <p className="instructions">
          The data from Reddit has been ingested and embedded successfully. There are{" "}
          {status?.reddit_items_count} posts/comments.
        </p>
      ) : (
        <>
          <p className="instructions">
            Click the button below to ingest the data from Reddit that has been
            manually downloaded.
          </p>
          <button onClick={handleClick} disabled={loading}>
            {loading ? "Running…" : "Run Ingestion"}
          </button>
        </>
      )}
      {error && <p className="error">{error}</p>}
    </section>
  );
}
