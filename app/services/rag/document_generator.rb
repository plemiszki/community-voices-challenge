module Rag
  # The RAG side of the A/B comparison: retrieves real excerpts from the
  # ingested corpus and asks Claude to write the Community Voices Document
  # grounded in them, with citations we build from the real permalinks
  # (never from whatever Claude writes) appended as a Sources section.
  class DocumentGenerator
    COMMUNITY = "r/gamedev"
    RETROSPECTIVE_QUERY = "What are the main topics and discussions in this community this week?"
    PROSPECTIVE_QUERY = "Unresolved questions, upcoming events, announced releases, planned follow-ups"

    def self.call(retriever: Rag::Retriever, claude_client: Claude::Client.new)
      new(retriever, claude_client).call
    end

    def initialize(retriever, claude_client)
      @retriever = retriever
      @claude_client = claude_client
    end

    def call
      RedditItem.ensure_embedded!
      content = claude_client.generate(system: system_prompt, user: user_prompt)
      "#{content}\n\n## Sources\n\n#{sources_list}"
    end

    private

    attr_reader :retriever, :claude_client

    def recent_items
      @recent_items ||= retriever.call(query: RETROSPECTIVE_QUERY, k: Retriever::DEFAULT_K)
    end

    def prospective_items
      @prospective_items ||= retriever.call(query: PROSPECTIVE_QUERY, k: Retriever::DEFAULT_K)
    end

    # Deduplicated, first-seen order — an item retrieved by both queries
    # keeps a single citation number instead of two conflicting ones.
    def cited_items
      @cited_items ||= (recent_items.to_a + prospective_items.to_a).uniq
    end

    def citation_number(item)
      cited_items.index(item) + 1
    end

    def system_prompt
      <<~PROMPT
        You are an analyst producing a "Community Voices Document" for the #{COMMUNITY} subreddit,
        covering the week of #{week_start} to #{week_end}.

        You are given two sets of real excerpts retrieved from #{COMMUNITY}, each numbered in brackets:

        RECENT DISCUSSION — this week's most representative posts and comments.
        FORWARD-LOOKING SIGNALS — excerpts hinting at unresolved questions, upcoming events, or planned
        follow-ups.

        Write a document with exactly two sections:
        1. "What #{COMMUNITY} talked about the week of #{week_start} to #{week_end}" — a synthesis
           grounded ONLY in the RECENT DISCUSSION excerpts. Cite excerpts inline using their bracket
           number, e.g. [3].
        2. "What we predict #{COMMUNITY} will talk about the following week" — a forward-looking
           prediction. You may extrapolate, but ground your reasoning in the FORWARD-LOOKING SIGNALS
           excerpts where possible, citing them the same way.

        Only cite excerpts that were actually given to you below. Do not invent URLs or citation
        numbers — a Sources list mapping each number to its real URL will be appended separately.

        Keep the whole document under 600 words.
      PROMPT
    end

    def user_prompt
      <<~PROMPT
        RECENT DISCUSSION:
        #{formatted_excerpts(recent_items)}

        FORWARD-LOOKING SIGNALS:
        #{formatted_excerpts(prospective_items)}
      PROMPT
    end

    def formatted_excerpts(items)
      items.map { |item| "[#{citation_number(item)}] #{item.embedding_text}" }.join("\n\n")
    end

    # A real markdown bullet list ("- " prefix) so each source renders as its
    # own line no matter how the markdown renderer treats plain line breaks —
    # bare "[n] url" lines joined by "\n" collapse into one run-on paragraph.
    def sources_list
      cited_items.each_with_index.map { |item, index| "- [#{index + 1}] #{item.permalink}" }.join("\n")
    end

    def week_start
      date_range.begin.strftime("%B %-d, %Y")
    end

    def week_end
      date_range.end.strftime("%B %-d, %Y")
    end

    def date_range
      @date_range ||= RedditItem.date_range
    end
  end
end
