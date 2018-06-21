class Bookmarks::SearchController < ApplicationController
  require_login!
  before_action :set_search, only: [ :show, :edit, :update, :destroy ]

  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    @bookmarks = fetch_bookmarks(default_query)

    respond_to do |format|
      format.html { render :index }
      format.json { render :index, status: :ok }
    end
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @query = params[:query].to_unsafe_h

    @search = current_user.searches.new query: @query
    authorize @search

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
    @search = current_user.searches.find(params[:id])

    authorize @search
  end

  def default_query
    return @query = {} if params[:q].blank? || params[:q].empty?

    @query ||= {
      should: [
        { id: 1, field: "title", operation: "match", values: [params[:q]] },
        { id: 2, field: "description", operation: "match", values: [params[:q]] },
        { id: 3, field: "tags", operation: "equal", values: [params[:q]] }
      ]
    }
  end

  def fetch_bookmarks query
    es_query = BookmarksSearcher.build query

    BookmarksIndex.query(term: { user_id: current_user.id }).query( es_query ).page(params[:page]).objects
  end
end
