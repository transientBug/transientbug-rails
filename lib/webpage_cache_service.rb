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

  autoload :Render, "webpage_cache_service/render"

  class Errors < Hash
    def add key, value
      self[key] ||= []
      self[key] << value
      self[key].uniq!
    end

    def each
      each_key do |field|
        self[field].each { |message| yield field, message }
      end
    end
  end

  class Cache
    attr_reader :uri, :key
    attr_accessor :headers

    def initialize uri:, key:
      @uri = uri
      @key = key
    end

    def errors
      @errors ||= Errors.new
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
      @root ||= ROOT.join(key.to_s)
    end

    def cache
      response = get uri: uri, path: original_html_path

      if response.code != 200
        errors.add uri, "Returned non-okay status code"
        return
      end

      link_map = cache_links

      metadata = {
        uri: uri.to_s,
        links: link_map
      }

      metadata_path.write metadata.to_json

      root
    end

    private

    def client
      @client ||= HTTP.headers headers
    end

    def get uri:, path:
      path.parent.mkpath

      response = client.get uri

      path.open "wb" do |file|
        file.write response.body
      end

      response
    end

    def asset_root
      @asset_root ||= root.join("assets")
    end

    def original_html_path
      @original_html_path ||= root.join("original.html")
    end

    def metadata_path
      @metadata_path ||= root.join("metadata.json")
    end

    def nokogiri
      @nokogiri ||= Nokogiri::HTML(original_html_path.open("r"))
    end

    def links
      @links ||= ASSET_XPATHS.flat_map(&nokogiri.method(:xpath))
        .map(&:to_s)
        .map(&Addressable::URI.method(:parse))
        .map { |link| uri + link }
    end

    def cache_links
      links.map do |link|
        link_key = Digest::SHA256.hexdigest link.to_s

        response = get uri: link, path: asset_root.join(link_key)
        if response.code != 200
          errors.add link, "Returned non-okay status code"
        end

        [ link_key, { link: link, content_type: response.content_type.mime_type } ]
      end.to_h
    end
  end
end
