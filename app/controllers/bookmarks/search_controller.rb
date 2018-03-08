class Bookmarks::SearchController < ApplicationController
  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    @bookmarks = BookmarkSearcher.new(params[:q])
      .search
      .objects
      .page params[:page]

    respond_to do |format|
      format.html { render :index }
      format.json { render :index, status: :ok }
    end
  end
end
