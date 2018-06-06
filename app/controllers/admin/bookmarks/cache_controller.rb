require "webpage_cache_service"

class Admin::Bookmarks::CacheController < AdminController
  before_action :set_bookmark

  # POST /bookmarks/1/cache
  def create
    WebpageCacheJob.perform_later bookmark: @bookmark

    redirect_to admin_bookmark_path(@bookmark), notice: "Bookmark queued to be recached"
  end

  private

  def set_bookmark
    @bookmark = policy_scope(Bookmark).find(params[:bookmark_id])
  end
end
