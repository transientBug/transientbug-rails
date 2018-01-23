class Api::V1::Bookmarks::CheckController < Api::V1Controller
  # GET /api/v1/bookmarks/check
  def index
    webpage = Webpage.find_by(uri_string: params[:url])
    head :not_found and return unless webpage

    bookmark = webpage.bookmarks.where(user: current_user).exists?
    head :not_found and return unless bookmark
    head :found
  end
end
