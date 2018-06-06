class Bookmarks::SearchController < ApplicationController
  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    @bookmarks = BookmarkSearcher.new
      .search(params)
      .query( term: { user_id: current_user.id } )
      .includes(
        :webpage,
        :tags,
        :user,
        offline_caches: [
          :error_messages
        ]
      )

    respond_to do |format|
      format.html { render :index }
      if @bookmarks.errors.any?
        format.json { render :error, status: 500 }
      else
        format.json { render :index, status: :ok }
      end
    end
  end
end
