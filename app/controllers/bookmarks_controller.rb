class BookmarksController < ApplicationController
  require_login!# only: [ :new, :edit, :create, :update, :destroy ]
  before_action :set_bookmark, only: [ :show, :edit, :update, :destroy ]
  before_action :set_tag, only: [ :tag ]

  # GET /bookmarks
  # GET /bookmarks.json
  def index
    @bookmarks = current_user.bookmarks.page params[:page]
  end

  # GET /bookmarks/tag/thing
  # GET /bookmarks/tag/thing.json
  def tag
    @bookmarks = current_user.bookmarks.where(tags: @tag).page params[:page]
  end

  # GET /bookmarks/1
  # GET /bookmarks/1.json
  def show
    respond_to do |format|
      format.html { render :show }
      format.json { render :show, status: :ok }
    end
  end

  # GET /bookmarks/tags/autocomplete.json
  def autocomplete
    @tags = tags_search.take(params.fetch(:c, 5))
      .tap { |arr| arr.unshift params[:q] }
      .uniq
      .compact

    respond_to do |format|
      format.json { render :autocomplete, status: :ok }
    end
  end

  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def search
    @bookmarks = BookmarksIndex.query(
      bool: {
        should: [
          { match: { title: params[:q] } },
          { match: { tags: params[:q] } }
        ]
      }
    ).objects.page params[:page]

    respond_to do |format|
      format.html { render :search }
      format.json { render :search, status: :ok }
    end
  end

  # GET /bookmarks/new
  def new
    @bookmark = current_user.bookmarks.new
    @bookmark.webpage = Webpage.new
  end

  # GET /bookmarks/1/edit
  def edit
  end

  # POST /bookmarks
  # POST /bookmarks.json
  def create
    @bookmark = current_user.bookmarks.new(bookmark_params)

    respond_to do |format|
      if @bookmark.save
        format.html { redirect_to @bookmark, notice: "Bookmark was successfully created." }
        format.json { render :show, status: :created, location: @bookmark }
      else
        format.html { render :new }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bookmarks/1
  # PATCH/PUT /bookmarks/1.json
  def update
    respond_to do |format|
      if @bookmark.update(bookmark_params)
        format.html { redirect_to @bookmark, notice: "Bookmark was successfully updated." }
        format.json { render :show, status: :ok, location: @bookmark }
      else
        format.html { render :edit }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookmarks/1
  # DELETE /bookmarks/1.json
  def destroy
    respond_to do |format|
      if @bookmark.destroy
        format.html { redirect_to bookmarks_url, notice: "Bookmark was successfully deleted." }
        format.json { head :no_content }
      else
        format.html { render :new }
        format.json { render json: @bookmark.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_bookmark
    @bookmark = current_user.bookmarks.find(params[:id])
  end

  def set_tag
    @tag = Tag.find_by(label: params[:tag])
  end

  def bookmark_params
    permitted_attributes(@bookmark || Bookmark).tap do |obj|
      tags = params.dig(:bookmark).fetch(:tags, []).map(&:strip).reject(&:empty?).map do |tag|
        Tag.find_or_create_by label: tag
      end

      webpage = Webpage.find_or_create_by uri_string: params.dig(:bookmark, :uri_string)

      obj.merge!(tags: tags, webpage: webpage)
    end
  end

  def tags_search
    res = BookmarksIndex.suggest(
      "tag-suggest" => {
        text: params[:q],
        completion: {
          field: :suggest,
          fuzzy: {
            fuzziness: 2
          },
          contexts: {
            type: [ :tag ]
          }
        }
      }
    )
    .suggest["tag-suggest"]

    tags ||= []
    tags += res.first["options"].map { |row| row.dig("_source", "tag") } if res.present?

    tags
  end
end

