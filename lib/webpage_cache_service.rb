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

  class Cache
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

    def cache
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
        .map do |link, offline_link|
          response = client.get link
          asset_root.join(offline_link).write response.body

          [ link, { key: offline_link, content_type: response.content_type.mime_type } ]
        end.to_h

      metadata = {
        uri: uri.to_s,
        links: link_map
      }

      root.join("metadata.json").write metadata.to_json

      root
    end

    private

    def client
      @client ||= HTTP.headers headers
    end
  end

  class Render
    attr_reader :key

    def initialize key:
      @key = key
    end

    def root
      @root ||= ROOT.join(key.to_s)
    end

    def metadata
      JSON.parse root.join("metadata.json").read
    end

    def content_type key:
      metadata["links"].values.find { |val| val["key"] == key }["content_type"]
    end

    def asset key:
      root.join("assets", key).open("r")
    end

    def render uri:, base_uri:
      base_path = root.join "original.html"

      nokogiri = Nokogiri::HTML(base_path.open("r"))

      ASSET_XPATHS.each do |xpath|
        nokogiri.xpath(xpath).each do |xpath_attr|
          link = uri + Addressable::URI.parse(xpath_attr.value)
          link_key = Digest::SHA256.hexdigest(link.to_s)

          xpath_attr.value = base_uri + link_key
        end
      end

      nokogiri.to_html
    end
  end
end
