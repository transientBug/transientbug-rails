# frozen_string_literal: true

require "tempfile"

class WebpageCacheService
  DEFAULT_HEADERS = {
    user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:106.0) Gecko/20100101 Firefox/106.0",
    accept_language: "en-US,en;q=0.5",
    accept: "text/html;q=0.9,*/*;q=0.8; charset=utf-8",
    accept_encoding: "gzip, deflate",
  }.freeze

  ASSET_XPATHS = [
    "//link[@rel='stylesheet']/@href",
    "//script/@src",
    "//img/@src"
  ].freeze

  LINK_XPATHS = [
    "//a/@href"
  ].freeze

  PARSABLE_MIMES = [
    "text/html",
    "application/xhtml+xml"
  ].freeze

  autoload :Errors, "webpage_cache_service/errors"
  autoload :Cache, "webpage_cache_service/cache"
  autoload :Render, "webpage_cache_service/render"
end
