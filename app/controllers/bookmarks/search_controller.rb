class Bookmarks::SearchController < ApplicationController
  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    @bookmarks = BookmarksIndex.query(
      bool: {
        should: [
          { match: { title: params[:q] } },
          { match: { tags: params[:q] } }
        ]
      }
    ).objects.page params[:page]

    respond_to do |format|
      format.html { render :index }
      format.json { render :index, status: :ok }
    end
  end
end
