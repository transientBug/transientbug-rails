class Bookmarks::SearchController < ApplicationController
  require_login!
  before_action :set_search, only: [ :show, :edit, :update, :destroy ]

  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    query = {
      should: [
        { id: 1, field: "title", operation: "match", values: ["earth"] },
        { id: 2, field: "description", operation: "match", values: ["earth"] }
      ],
      must: [
        { id: 3, field: "tags", operation: "equal", values: ["computers"] },
        {
          id: 4,
          must: [
            { id: 7, field: "title", operation: "exist" },
            { id: 5, field: "created_at", operation: "[between]", values: ["2014-01-01", "2018-06-14"] },
          ]
        }
      ],
      must_not: [
        { id: 6, field: "host", operation: "equal", values: ["wired.com"] }
      ]
    }

    unless params[:q].blank? || params[:q].empty?
      query = {
        should: [
          { id: 1, field: "title", operation: "match", values: [params[:q]] },
          { id: 2, field: "description", operation: "match", values: [params[:q]] },
          { id: 3, field: "tags", operation: "equal", values: [params[:q]] }
        ]
      }
    end

    @config_and_query = query_builder_config query

    @bookmarks = fetch_bookmarks(query)

    respond_to do |format|
      format.html { render :index }
      format.json { render :index, status: :ok }
    end
  end

  def create
    query = params[:query].to_unsafe_h

    @search = current_user.searches.new query: query.to_json

    authorize @search

    if @search.save
      render json: { location: bookmarks_search_path(@search) }, status: :created, location: bookmarks_search_path(@search)
    else
      render json: { errors: @search.errors }, status: :unprocessable_entity
    end
  end

  def show
    query = JSON.parse(@search.query).with_indifferent_access

    @config_and_query = query_builder_config query

    @bookmarks = fetch_bookmarks(query)

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

  def query_builder_config query
    {
      fields: BookmarksSearcher.fields,
      config: BookmarksSearcher.config,
      query: query
    }
  end

  def elastic_query query
    bool = query.slice(*BookmarksSearcher.config[:joiners].keys).each_with_object({}) do |(joiner, values), memo|
      memo[ joiner ] = values.map do |value|
        unless value.key? :field
          next elastic_query value
        end

        BookmarksSearcher.operations[ value[:operation] ][:block].call value[:field], value[:values]
      end
    end

    {
      bool: bool
    }
  end

  def fetch_bookmarks query
    es_query = elastic_query(query)

    BookmarksIndex.query( es_query ).page(params[:page]).objects
  end
end
