require "webpage_cache_service"

class WebpageCacheJob < ApplicationJob
  queue_as :default
  attr_reader :bookmark

  def perform bookmark:
    WebpageCacheService::Cache.new(webpage: bookmark.webpage).exec
  end
end
