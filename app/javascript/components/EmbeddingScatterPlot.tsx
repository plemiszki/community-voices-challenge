import { useEffect, useState } from "react"
import { CartesianGrid, Legend, Scatter, ScatterChart, Tooltip, XAxis, YAxis } from "recharts"
import { fetchEmbeddingsVisualization } from "../api/client"
import type { EmbeddingPoint, ItemType } from "../types/api"

// Validated categorical palette (see dataviz skill: 2-slot all-pairs check
// passes in both light and dark modes) plus chart chrome tokens, mirroring
// the CSS custom properties in application.css.
const COLORS = {
  light: { surface: "#fcfcfb", muted: "#898781", gridline: "#e1e0d9", baseline: "#c3c2b7", post: "#2a78d6", comment: "#eb6834" },
  dark: { surface: "#1a1a19", muted: "#898781", gridline: "#2c2c2a", baseline: "#383835", post: "#3987e5", comment: "#d95926" },
}

const MIN_RADIUS = 4
const RADIUS_SCALE = 2.5

const SERIES: { type: ItemType; label: string }[] = [
  { type: "post", label: "Posts" },
  { type: "comment", label: "Comments" },
]

function usePrefersDark(): boolean {
  const [prefersDark, setPrefersDark] = useState(
    () => window.matchMedia("(prefers-color-scheme: dark)").matches,
  )

  useEffect(() => {
    const query = window.matchMedia("(prefers-color-scheme: dark)")
    const listener = (event: MediaQueryListEvent) => setPrefersDark(event.matches)
    query.addEventListener("change", listener)
    return () => query.removeEventListener("change", listener)
  }, [])

  return prefersDark
}

// Radius encodes retrieval_count by area (via sqrt), not radius directly,
// matching how people actually perceive circle size differences.
function radiusFor(retrievalCount: number): number {
  return MIN_RADIUS + Math.sqrt(retrievalCount) * RADIUS_SCALE
}

function pointShape(fill: string, surface: string) {
  return (props: any) => (
    <circle cx={props.cx} cy={props.cy} r={radiusFor(props.payload.retrieval_count)} fill={fill} stroke={surface} strokeWidth={2} />
  )
}

function EmbeddingTooltip({ active, payload }: any) {
  if (!active || !payload?.length) return null

  const point: EmbeddingPoint = payload[0].payload
  return (
    <div className="chart-tooltip">
      <p className="chart-tooltip-value">{point.retrieval_count} retrievals</p>
      <p className="chart-tooltip-label">{point.item_type}</p>
      <p className="chart-tooltip-snippet">{point.snippet}</p>
    </div>
  )
}

interface Props {
  ingested: boolean
  refreshKey: number
}

export default function EmbeddingScatterPlot({ ingested, refreshKey }: Props) {
  const [points, setPoints] = useState<EmbeddingPoint[]>([])
  const [error, setError] = useState<string | null>(null)
  const theme = usePrefersDark() ? COLORS.dark : COLORS.light

  useEffect(() => {
    if (!ingested) return

    fetchEmbeddingsVisualization()
      .then(setPoints)
      .catch((err) => setError(err instanceof Error ? err.message : "Failed to load embeddings"))
  }, [ingested, refreshKey])

  return (
    <section className="panel">
      <h2>Embedding Space</h2>
      {error && <p className="error">{error}</p>}
      {!ingested ? (
        <p className="instructions">Run ingestion to see visualization.</p>
      ) : (
        <ScatterChart width={640} height={420} margin={{ top: 16, right: 16, bottom: 16, left: 16 }}>
          <CartesianGrid stroke={theme.gridline} />
          <XAxis type="number" dataKey="x" tick={{ fill: theme.muted }} stroke={theme.baseline} />
          <YAxis type="number" dataKey="y" tick={{ fill: theme.muted }} stroke={theme.baseline} />
          <Tooltip content={<EmbeddingTooltip />} cursor={{ strokeDasharray: "3 3" }} />
          <Legend />
          {SERIES.map((series) => (
            <Scatter
              key={series.type}
              name={series.label}
              data={points.filter((point) => point.item_type === series.type)}
              fill={theme[series.type]}
              shape={pointShape(theme[series.type], theme.surface)}
            />
          ))}
        </ScatterChart>
      )}
    </section>
  )
}
