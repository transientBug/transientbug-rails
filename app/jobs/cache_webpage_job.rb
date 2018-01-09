require "webpage_cache_service"

class CacheWebpageJob < ApplicationJob
  queue_as :default
  attr_reader :bookmark

  def perform bookmark:
    @bookmark = bookmark

    download_original
  end

  private

  def download_original
    WebpageCacheService::Cache.new(uri: bookmark.uri, key: bookmark.id).cache
  end
end
