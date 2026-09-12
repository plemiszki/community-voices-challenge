import { useState } from "react";
import { generateDocuments } from "../api/client";
import type { CommunityVoicesDocuments } from "../types/api";
import CommunityVoicesDocument from "./CommunityVoicesDocument";

interface Props {
  ingested: boolean;
  onGenerated: () => void;
}

export default function DocumentComparison({ ingested, onGenerated }: Props) {
  const [documents, setDocuments] = useState<CommunityVoicesDocuments | null>(
    null,
  );
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleClick() {
    setLoading(true);
    setError(null);
    try {
      setDocuments(await generateDocuments());
      onGenerated();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Generation failed");
    } finally {
      setLoading(false);
    }
  }

  const generated = documents !== null;

  return (
    <section className="panel">
      <h2>
        Step 2 - Generation
        {generated && (
          <span className="status-check" aria-label="Generated">
            ✓
          </span>
        )}
      </h2>
      {generated ? (
        <p className="instructions">The documents have been generated successfully. See below.</p>
      ) : (
        <>
          <p className="instructions">
            Click the button below to generate two "Community Voices" documents. One
            with RAG (Retrieval-Augmented-Generation), and one without. This could
            take up to a minute.
          </p>
          {!ingested && (
            <p className="instructions blocked-message">
              You must complete the previous step before generating these documents.
            </p>
          )}
          <button onClick={handleClick} disabled={loading || !ingested}>
            {loading ? "Generating…" : "Generate Documents"}
          </button>
        </>
      )}
      {error && <p className="error">{error}</p>}
      {documents && (
        <div className="comparison">
          <CommunityVoicesDocument title="With RAG" content={documents.rag} />
          <CommunityVoicesDocument
            title="Without RAG (baseline)"
            content={documents.baseline}
          />
        </div>
      )}
    </section>
  );
}
