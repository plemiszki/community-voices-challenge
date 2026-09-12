module Baseline
  # The "LLM without RAG" side of the A/B comparison: asks Claude to write
  # the Community Voices Document from general knowledge alone, with no
  # retrieved context at all.
  class DocumentGenerator
    COMMUNITY = "r/gamedev"

    def self.call(claude_client: Claude::Client.new)
      new(claude_client).call
    end

    def initialize(claude_client)
      @claude_client = claude_client
    end

    def call
      RedditItem.ensure_ingested!
      claude_client.generate(system: system_prompt, user: user_prompt)
    end

    private

    attr_reader :claude_client

    def system_prompt
      <<~PROMPT
        You are an analyst producing a "Community Voices Document" for the #{COMMUNITY} subreddit.
        You have no access to live data or real posts from this community, and no data was retrieved
        for you — rely only on your general knowledge of this community and communities like it.

        Write a document with exactly two sections:
        1. "What #{COMMUNITY} talked about the week of #{week_start} to #{week_end}" — your best
           general sense of likely topics.
        2. "What we predict #{COMMUNITY} will talk about the following week" — a forward-looking
           prediction.

        Do not fabricate specific post titles, usernames, or URLs — you have no real data to draw from,
        so write in general terms rather than inventing specifics.

        Keep the whole document under 600 words.
      PROMPT
    end

    def user_prompt
      "Community: #{COMMUNITY}. The week to analyze runs from #{week_start} through #{week_end}."
    end

    def week_start
      date_range.begin.strftime("%B %-d, %Y")
    end

    def week_end
      date_range.end.strftime("%B %-d, %Y")
    end

    # Anchored to the real span of ingested data, not today's system date —
    # so this and the RAG generator are always asked about the same week.
    def date_range
      @date_range ||= RedditItem.date_range
    end
  end
end
