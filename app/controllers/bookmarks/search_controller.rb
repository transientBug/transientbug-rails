class Bookmarks::SearchController < ApplicationController
  require_login!
  before_action :set_search, only: [ :show, :edit, :update, :destroy ]

  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    @bookmarks = fetch_bookmarks default_query

    respond_to do |format|
      format.html { render :index }
      format.json { render :index, status: :ok }
    end
  end

  # POST /bookmarks/search
  # POST /bookmarks/search.json
  # rubocop:disable Metrics/AbcSize
  def create
    @query = params[:query].to_unsafe_h

    @search = authorize current_user.searches.new(query: @query)

    respond_to do |format|
      if @search.save
        format.html { redirect_to bookmarks_search_path(@search) }
        format.json { render :show, status: :created, location: bookmarks_search_path(@search) }
      else
        format.html { render :new }
        format.json { render json: @search.errors, status: :unprocessable_entity }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # GET /bookmarks/search/1
  # GET /bookmarks/search/1.json
  def show
    @query = @search.query.with_indifferent_access
    @bookmarks = fetch_bookmarks(@query)

    respond_to do |format|
      format.html { render :index }
      format.json { render :index, status: :ok }
    end
  end

  protected

  def set_search
    @search = authorize current_user.searches.find(params[:id])
  end

  # rubocop:disable Naming/MemoizedInstanceVariableName
  def default_query
    return @query ||= {} if params[:q].blank? || params[:q].empty?

    @query ||= {
      should: [
        { id: 1, field: "title", operation: "match", values: [params[:q]] },
        { id: 2, field: "description", operation: "match", values: [params[:q]] },
        { id: 3, field: "tags", operation: "equal", values: [params[:q]] }
      ]
    }
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def fetch_bookmarks query
    searcher = policy_scope(BookmarksSearcher).query query
    searcher.page(params[:page]).per(params[:per_page])

    searcher.activerecord_modifier do |ar_results|
      ar_results.includes(
        :webpage,
        :tags,
        :user,
        offline_caches: [
          :error_messages
        ]
      )
    end

    searcher
  end
end
