import { useEffect, useState } from "react";
import { fetchRetrievalStats } from "../api/client";
import type { RetrievalStatItem } from "../types/api";

interface Props {
  ingested: boolean;
  refreshKey: number;
}

export default function RetrievalStatsTable({ ingested, refreshKey }: Props) {
  const [items, setItems] = useState<RetrievalStatItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!ingested) return;

    setLoading(true);
    fetchRetrievalStats()
      .then(setItems)
      .catch((err) =>
        setError(
          err instanceof Error ? err.message : "Failed to load retrieval stats",
        ),
      )
      .finally(() => setLoading(false));
  }, [ingested, refreshKey]);

  return (
    <section className="panel">
      <h2>Most Retrieved</h2>
      {error && <p className="error">{error}</p>}
      {!ingested ? (
        <p className="instructions">
          Run ingestion to see which items have the most retrievals.
        </p>
      ) : loading ? (
        <p className="instructions">Loading…</p>
      ) : items.length === 0 ? (
        <p className="instructions">
          There are currently no posts or comments with retrievals. Click the
          "Generate Documents" button to start retrieving items.
        </p>
      ) : (
        <table>
          <thead>
            <tr>
              <th>Type</th>
              <th>Excerpt</th>
              <th>Retrievals</th>
            </tr>
          </thead>
          <tbody>
            {items.map((item) => (
              <tr key={item.id}>
                <td>{item.item_type}</td>
                <td>
                  <a href={item.permalink} target="_blank" rel="noreferrer">
                    {item.snippet}
                  </a>
                </td>
                <td>{item.retrieval_count}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </section>
  );
}
