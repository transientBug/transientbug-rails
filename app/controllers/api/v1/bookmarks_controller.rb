class Api::V1::BookmarksController < Api::V1Controller
  before_action :set_bookmark, only: [:show, :update, :destroy]

  # GET /api/v1/bookmarks
  def index
    @bookmarks = policy_scope(current_user.bookmarks).page params[:page]
  end

  # GET /api/v1/bookmarks/1
  def show; end

  # POST /api/v1/bookmarks
  def create
    @bookmark = Bookmark.for(current_user, params.dig(:data, :attributes, :url)) do |bookmark|
      authorize bookmark

      bookmark.title = upsert_params(:title, bookmark)
      bookmark.description = upsert_params(:description, bookmark)

      bookmark.tags = upsert_params(:tags, bookmark)
    end

    if @bookmark.upsert
      render :show, status: :created, location: @bookmark
    else
      render json: @bookmark.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/bookmarks/1
  def update
    if @bookmark.update(update_params)
      render :show, status: :ok, location: @bookmark
    else
      render json: @bookmark.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/bookmarks/1
  def destroy
    @bookmark.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bookmark
    @bookmark = current_user.bookmarks.find(params[:id])
    authorize @bookmark
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bookmark_params
    params.require(:data).require(:attributes).permit(:title, :description, tags: [])
  end

  def update_params
    bookmark_params.tap do |obj|
      obj[:tags] = Tag.find_or_create_tags tags: obj[:tags]
    end
  end

  def upsert_params key, bookmark
    return upsert_tags bookmark if key == :tags

    bookmark_params[key] || bookmark&.send(key)
  end

  def upsert_tags bookmark
    base = []

    base.concat(bookmark_params[:tags].to_a)
    base.concat(bookmark&.tags.to_a)

    base.uniq
  end
end
