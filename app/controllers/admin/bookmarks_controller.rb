class Admin::BookmarksController < AdminController
  before_action :set_count
  before_action :set_bookmark, only: [ :show, :destroy ]

  # GET /bookmarks
  def index
    bookmark_table = Bookmark.arel_table

    query_param = params[:q]
    base_where = bookmark_table[:id].eq(query_param)

    @bookmarks = Bookmark.includes(:webpage, :tags, :user).all
    @bookmarks = @bookmarks.where(base_where) if query_param.present? && !query_param.empty?
    @bookmarks = @bookmarks.order(created_at: :desc).page params[:page]
  end

  # GET /bookmarks/1
  def show
    respond_to do |format|
      format.html { render :show }
    end
  end

  def destroy
    respond_to do |format|
      if @bookmark.destroy
        format.html { redirect_to admin_bookmarks_url, notice: "Bookmark was successfully deleted." }
      else
        format.html { render :new }
      end
    end
  end

  private

  def set_bookmark
    @bookmark = Bookmark.includes(
      :webpage,
      :tags,
      :user,
      offline_caches: [
        :error_messages,
        :assets_attachments,
        :assets_blobs
      ]
    ).find params[:id]
  end

  def set_count
    @count = Bookmark.count
  end
end
