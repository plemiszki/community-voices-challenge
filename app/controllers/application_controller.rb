class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from RedditItem::NotIngestedError, RedditItem::NotEmbeddedError, with: :render_ingestion_error

  def root
    render "root", formats: [ :html ]
  end

  private

  def render_ingestion_error(error)
    render json: { error: error.message }, status: :unprocessable_content
  end
end
