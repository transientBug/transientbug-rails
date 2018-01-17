class Admin::BookmarksController < AdminController
  before_action :set_count
  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]

  # GET /bookmarks
  def index
    @bookmarks = Bookmark.all.order(created_at: :desc).page params[:page]
  end

  # GET /bookmarks/1
  def show
    respond_to do |format|
      format.html { render :show }
    end
  end

  # GET /bookmarks/1/edit
  def edit
  end

  # PATCH/PUT /bookmarks/1
  def update
    respond_to do |format|
      if @bookmark.update(bookmark_params)
        format.html { redirect_to [:admin, @bookmark], notice: "Bookmark was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  private

  def set_bookmark
    @bookmark = Bookmark.find params[:id]
  end

  def set_count
    @count = Bookmark.count
  end

  def bookmark_params
    params.require(:bookmark).permit(:title).tap do |obj|
      # TODO: tags, uri
    end
  end
end
