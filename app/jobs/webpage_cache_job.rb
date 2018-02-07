require "webpage_cache_service"

class WebpageCacheJob < ApplicationJob
  queue_as :default
  attr_reader :bookmark

  def perform bookmark:
    service = WebpageCacheService.new(webpage: bookmark.webpage).exec
    bookmark.current_offline_cache = service.offline_cache
  end
end
