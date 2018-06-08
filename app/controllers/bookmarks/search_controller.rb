class Bookmarks::SearchController < ApplicationController
  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    @query = params[:q]
    @searcher = policy_scope(BookmarkSearcher)

    if @query.blank? || @query.empty?
      @bookmarks = Bookmark.none
    else
      if @query
        odd_quotes = @query.count('"').odd?
        @query = @query + '"' if odd_quotes

        @searcher.query @query
        @searcher.errors.add :query, "Quotation marks were unbalanced, an extra quote was added to the end of the query" if odd_quotes
      end

      @bookmarks = @searcher.results
        .includes(
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
      if @searcher.errors.any?
        format.json { render :error, status: 500 }
      else
        format.json { render :index, status: :ok }
      end
    end
  end
end
