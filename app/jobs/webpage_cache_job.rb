require "webpage_cache_service"

class WebpageCacheJob < ApplicationJob
  queue_as :default
  attr_reader :bookmark

  def perform bookmark:
    service = WebpageCacheService::Cache.new(webpage: bookmark.webpage).exec
    bookmark.offline_caches << service.offline_cache
  end
end
