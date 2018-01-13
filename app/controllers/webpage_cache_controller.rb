require "webpage_cache_service"

class WebpageCacheController < ApplicationController
  BASE_TEMPLATE = Addressable::Template.new("/bookmarks/{id}/cache/assets/")

  require_login!# only: [ :new, :edit, :create, :update, :destroy ]
  before_action :set_bookmark

  def index
    base_uri = BASE_TEMPLATE.expand id: params[:bookmark_id]
    render html: renderer.render(uri: @bookmark.uri, base_uri: base_uri).html_safe
  end

  def assets
    render plain: "404 Not Found", status: :not_found and return unless renderer.asset?(key: params[:key])
    send_data renderer.asset(key: params[:key]).read, type: renderer.content_type(key: params[:key]), disposition: "inline"
  end

  private

  def set_bookmark
    @bookmark = policy_scope(Bookmark).find(params[:bookmark_id])
  end

  def renderer
    @renderer ||= WebpageCacheService::Render.new(key: params[:bookmark_id])
  end
end
