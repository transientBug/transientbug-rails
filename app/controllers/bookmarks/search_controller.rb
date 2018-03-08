class Bookmarks::SearchController < ApplicationController
  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    scope = policy_scope(Bookmark)

    @bookmarks = BookmarkSearcher.new(scope)
      .search(params)
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
      format.json { render :index, status: :ok }
    end
  end
end
