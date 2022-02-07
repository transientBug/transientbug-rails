# frozen_string_literal: true

require "webpage_cache_service"

class Bookmarks::CacheController < ApplicationController
  BASE_TEMPLATE = Addressable::Template.new("/bookmarks/{id}/cache/")

  require_login!
  before_action :set_bookmark

  # rubocop:disable Rails/OutputSafety
  # GET /bookmarks/1/cache
  def index
    render :unavailable, status: :not_found unless @bookmark.current_offline_cache

    root_blob = @bookmark.current_offline_cache.root.blob
    render :unavailable, status: :not_found unless root_blob.service.exist? root_blob.key

    render html: renderer.render.html_safe
  end
  # rubocop:enable Rails/OutputSafety

  # POST /bookmarks/1/cache
  def create
    WebpageCacheJob.perform_later bookmark: @bookmark

    redirect_to bookmark_path(@bookmark), notice: "Bookmark queued to be recached"
  end

  # GET /bookmarks/1/cache/123abc
  def show
    key = params[:key]

    render(plain: "404 Not Found", status: :not_found) && return unless renderer.asset?(key:)

    send_data renderer.asset(key:).read, type: renderer.content_type(key:), disposition: "inline"
  end

  private

  def set_bookmark
    @bookmark = policy_scope(Bookmark).find(params[:bookmark_id])
  end

  def renderer
    @renderer ||= WebpageCacheService::Render.new(offline_cache: @bookmark.current_offline_cache, base_uri:)
  end

  def base_uri
    @base_uri ||= BASE_TEMPLATE.expand id: params[:bookmark_id]
  end
end
