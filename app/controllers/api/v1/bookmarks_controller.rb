class Api::V1::BookmarksController < Api::V1Controller
  before_action :set_bookmark, only: [:show, :update, :destroy]

  # GET /api/v1/bookmarks
  def index
    @bookmarks = current_user.bookmarks.all.page params[:page]
  end

  # GET /api/v1/bookmarks/1
  def show; end

  # POST /api/v1/bookmarks
  def create
    # TODO: find_or_create_by has a race condition and I don't have unique
    # indexes on these yet as there is some cleanup around the uri string that
    # I want to do first
    webpage = Webpage.find_or_create_by(uri_string: params.dig(:data, :attributes, :url))
    @bookmark = webpage.bookmarks.find_or_initialize_by(user: current_user)

    if @bookmark.new_record?
      @bookmark.update bookmark_params
      if @bookmark.save
        render :show, status: :created, location: @bookmark
      else
        render json: @bookmark.errors, status: :unprocessable_entity
      end
    else
      render :show, status: :created, location: @bookmark
    end
  end

  # PATCH/PUT /api/v1/bookmarks/1
  def update
    if @bookmark.update(bookmark_params)
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
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def bookmark_params
    params.require(:data).require(:attributes).permit(:title)
  end
end
