class Bookmarks::SearchController < ApplicationController
  require_login!

  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    @bookmarks = fetch_bookmarks params[:q]

    respond_to do |format|
      format.html { render :index }
      format.json { render :index, status: :ok }
    end
  end

  protected

  def fetch_bookmarks query
    scope = lambda do
      includes(
        :webpage,
        :tags,
        :user,
        offline_caches: [
          :error_messages
        ]
      )
    end

    BookmarksSearcher.new.search(query)
      .query(term: { user_id: current_user.id })
      .page(params[:page])
      .per(params[:per_page])
      .load(scope: scope)
      .objects
  end
end
