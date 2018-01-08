class WebpageCacheService
  DEFAULT_HEADERS = {
    user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:57.0) Gecko/20100101 Firefox/57.0",
    accept_language: "en-US,en;q=0.5",
    accept: "application/html;q=0.9,*/*;q=0.8; charset=utf-8"
  }.freeze

  ROOT = Rails.root.join("storage", "webpage_caches").freeze

  ASSET_XPATHS = [
    "//link[@rel='stylesheet']/@href",
    "//script/@src",
    "//img/@src"
  ].freeze

  attr_reader :uri, :key
  attr_accessor :headers

  def initialize uri:, key:
    @uri = uri
    @key = key
  end

  def headers
    @headers ||= DEFAULT_HEADERS.dup
  end

  def set_header key, value
    headers[ key ] = value
  end

  def clear_header key
    headers.delete key
  end

  def root
    @root ||= ROOT.join(key.to_s).tap do |path|
      path.mkpath
    end
  end

  def cache!
    base_response = client.get uri

    base_path = root.join "original.html"
    base_path.write base_response.body

    nokogiri = Nokogiri::HTML(base_path.open("r"))

    asset_root = root.join("assets").tap do |path|
      path.mkpath
    end

    link_map = ASSET_XPATHS.flat_map(&nokogiri.method(:xpath))
      .map(&:to_s)
      .map(&Addressable::URI.method(:parse))
      .map { |link| uri + link }
      .map { |link| [ link, Digest::SHA256.hexdigest(link.to_s) ] }
      .to_h

    link_map.each do |link, offline_link|
      response = client.get link
      asset_root.join(offline_link).write response.body
    end

    root.join("linkmap.json").write link_map.to_json

    root
  end

  private

  def client
    @client ||= HTTP.headers headers
  end
end
