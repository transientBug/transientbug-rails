require "webpage_cache_service"

class WebpageCacheJob < ApplicationJob
  queue_as :default
  attr_reader :bookmark

  rescue_from(ActiveJob::DeserializationError) do |exception|
    Rails.logger.debug "Failed to find parameters"
    Rails.logger.debug exception
  end

  def perform bookmark:
    service = WebpageCacheService::Cache.new(webpage: bookmark.webpage).exec
    bookmark.offline_caches << service.offline_cache
  end
end
