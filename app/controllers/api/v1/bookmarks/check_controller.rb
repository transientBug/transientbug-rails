class Api::V1::Bookmarks::CheckController < Api::V1Controller
  # GET /api/v1/bookmarks/check
  def index
    head :not_found and return unless bookmark_found?
    head :found
  end

  protected

  def bookmark_found?
    BookmarksIndex.query(
      bool: {
        must: [
          { term: { uri: params[:url] } },
          { term: { user_id: current_user.id } }
        ]
      }
    ).any?
  end
end
