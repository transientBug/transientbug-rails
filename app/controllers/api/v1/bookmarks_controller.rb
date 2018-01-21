class Api::V1::BookmarksController < Api::V1Controller
  before_action :set_bookmark, only: [:show, :update, :destroy]

  # GET /api/v1/bookmarks
  # GET /api/v1/bookmarks.json
  def index
    @bookmarks = current_user.bookmarks.all
  end

  # GET /api/v1/bookmarks/1
  # GET /api/v1/bookmarks/1.json
  def show
  end

  # POST /api/v1/bookmarks
  # POST /api/v1/bookmarks.json
  def create
    # TODO: webpage find_or_create_by has a race condition
    @bookmark = current_user.bookmarks.new(bookmark_params)
    @bookmark.webpage = Webpage.find_or_create_by uri_string: params.dig(:url)

    if @bookmark.save
      render :show, status: :created, location: @bookmark
    else
      render json: @bookmark.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/bookmarks/1
  # PATCH/PUT /api/v1/bookmarks/1.json
  def update
    if @bookmark.update(bookmark_params)
      render :show, status: :ok, location: @bookmark
    else
      render json: @bookmark.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/bookmarks/1
  # DELETE /api/v1/bookmarks/1.json
  def destroy
    @bookmark.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_bookmark
    @bookmark = current_user.bookmarks.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bookmark_params
    params.permit(:title)
  end
end
