require "tempfile"

class WebpageCacheService
  DEFAULT_HEADERS = {
    user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:57.0) Gecko/20100101 Firefox/57.0",
    accept_language: "en-US,en;q=0.5",
    accept: "text/html;q=0.9,*/*;q=0.8; charset=utf-8"
  }.freeze

  ROOT = Rails.root.join("storage", "webpage_caches").freeze

  ASSET_XPATHS = [
    "//link[@rel='stylesheet']/@href",
    "//script/@src",
    "//img/@src"
  ].freeze

  PARSABLE_MIMES = [
    "text/html",
    "application/xhtml+xml"
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
    attr_reader :uri, :offline_cache
    attr_accessor :headers

    def initialize webpage:
      @webpage = webpage
      @uri = webpage.uri.to_s
      @offline_cache = webpage.offline_caches.create
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

    # Return self since there is an errors object and the offline cache model
    # that people might care about on this object.
    def exec
      cache
      self
    end

    private

    def cache
      response, root_attachment = get uri: uri
      @root_attachment = root_attachment

      offline_cache.tap do |obj|
        obj.root = @root_attachment
        obj.save
      end

      if response&.status > 399
        errors.add uri, "Got non-okay status back from the server: #{ response&.status }"
        return
      end

      return unless PARSABLE_MIMES.include? response.content_type.mime_type

      links.each { |link| get uri: link }
    end

    def client
      @client ||= HTTP.headers(headers).follow
    end

    def get uri:
      response = client.get uri

      content_type = response.content_type.mime_type

      temp_key = Digest::SHA256.hexdigest uri.to_s
      attachment = Tempfile.create temp_key do |temp_file|
        temp_file.binmode

        response.body.each do |partial|
          temp_file.write partial
        end

        temp_file.rewind

        # some websites *cough*offline.pink*cough* don't return a content type
        # header, so we'll first see if the html doctype string is present and
        # guess this is text/html or we'll fallback to assuming its binary
        unless content_type
          content_type = "text/html" if Nokogiri::XML(temp_file).errors.empty?
          # binding.pry
          content_type ||= "application/octet-stream"
        end

        temp_file.rewind

        offline_cache.assets.attach(
          io: temp_file,
          filename: uri.to_s,
          content_type: content_type,
          metadata: {
            status_code: response.code,
            headers: response.headers.to_h
          }
        )&.first
      end

      [ response, attachment ]
    end

    def nokogiri
      @nokogiri ||= Nokogiri::HTML(@root_attachment.blob.download)
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
