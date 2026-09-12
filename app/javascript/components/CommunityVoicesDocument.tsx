import DOMPurify from "dompurify"
import { marked } from "marked"

interface Props {
  title: string
  content: string
}

export default function CommunityVoicesDocument({ title, content }: Props) {
  const html = DOMPurify.sanitize(marked.parse(content, { async: false, breaks: true }))

  return (
    <div className="document">
      <h3>{title}</h3>
      <div className="document-content" dangerouslySetInnerHTML={{ __html: html }} />
    </div>
  )
}
