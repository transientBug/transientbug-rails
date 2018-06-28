class Bookmarks::SearchController < ApplicationController
  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    @query = params[:q]
    @bookmarks = policy_scope(BookmarkSearcher).query @query
    @bookmarks.page(params[:page]).per(params[:per_page])

    @bookmarks.activerecord_modifier do |ar_results|
      ar_results.includes(
        :webpage,
        :tags,
        :user,
        offline_caches: [
          :error_messages
        ]
      )
    end

    respond_to do |format|
      format.html { render :index }
      format.json { render :index, status: :ok }
    end
  end
end
