require "webpage_cache_service"

class Bookmarks::CacheController < ApplicationController
  BASE_TEMPLATE = Addressable::Template.new("/bookmarks/{id}/cache/")

  require_login!
  before_action :set_bookmark

  # GET /bookmarks/1/cache
  def index
    render status: :not_found unless @bookmark.current_offline_cache
    base_uri = BASE_TEMPLATE.expand id: params[:bookmark_id]
    render html: renderer.render(base_uri: base_uri).html_safe
  end

  # POST /bookmarks/1/cache
  def create
    WebpageCacheJob.perform_later bookmark: @bookmark

    redirect_to bookmark_path(@bookmark), notice: "Bookmark queued to be recached"
  end

  # GET /bookmarks/1/cache/123abc
  def show
    key = params[:key]

    render plain: "404 Not Found", status: :not_found and return unless renderer.asset?(key: key)
    send_data renderer.asset(key: key).read, type: renderer.content_type(key: key), disposition: "inline"
  end

  private

  def set_bookmark
    @bookmark = policy_scope(Bookmark).find(params[:bookmark_id])
  end

  def renderer
    @renderer ||= WebpageCacheService::Render.new(offline_cache: @bookmark.current_offline_cache)
  end
end
