class Bookmarks::SearchController < ApplicationController
  require_login!
  before_action :set_search, only: [ :show, :edit, :update, :destroy ]

  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    @bookmarks = fetch_bookmarks query

    respond_to do |format|
      format.html { render :index }
      format.json { render :index, status: :ok }
    end
  end

  # POST /bookmarks/search
  # POST /bookmarks/search.json
  def create
    @search = authorize current_user.searches.new(query: query)

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

  # GET /bookmarks/search/1
  # GET /bookmarks/search/1.json
  def show
    @query = @search.query.with_indifferent_access
    @bookmarks = fetch_bookmarks(query)

    respond_to do |format|
      format.html { render :index }
      format.json { render :index, status: :ok }
    end
  end

  helper_method :query

  protected

  def set_search
    @search = authorize current_user.searches.find(params[:id])
  end

  def query
    @query ||= params[:query]&.to_unsafe_h
    @query ||= BookmarksSearcher.default_query params[:q]
  end

  def fetch_bookmarks query
    searcher = policy_scope(BookmarksSearcher).query query do |chewy|
      chewy.order(created_at: { order: :desc })
    end

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
