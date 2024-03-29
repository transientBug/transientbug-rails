# frozen_string_literal: true

require "tempfile"

class WebpageCacheService
  class Cache
    extend Forwardable

    attr_reader :offline_cache

    def initialize bookmark:
      @bookmark = bookmark
      @offline_cache = bookmark.offline_caches.create
    end

    def_delegator :@bookmark, :uri

    def errors
      offline_cache.error_messages
    end

    def successful?
      @errors.empty?
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

    def exec
      cache_root

      return self unless PARSABLE_MIMES.include? @root_attachment.blob.content_type

      cache_links

      # Return self since there is an errors object and the offline cache model
      # that people might care about on this object.
      self
    end

    private

    def cache_root
      _response, root_attachment = get uri: uri
      @root_attachment = root_attachment

      offline_cache.tap do |obj|
        obj.root = @root_attachment
        obj.save
      end
    rescue => e
      errors.create key: uri, message: e.message
      self
    end

    def cache_links
      links.each do |link|
        get uri: link
      rescue => e
        errors.create key: link, message: e.message
        self
      end
    end

    # this has some serious memory implications since it reads the whole file
    # in, but hopefully people don't have gigabyte sized HTML pages
    def nokogiri
      @nokogiri ||= Nokogiri::HTML(@root_attachment.blob.download)
    end

    def links
      @links ||= ASSET_XPATHS.flat_map(&nokogiri.method(:xpath))
        .map(&:to_s)
        .uniq
        .compact
        .reject { |link| link.start_with? "data:" }
        .map(&Addressable::URI.method(:parse))
        .map(&method(:derelative))
        .map(&:to_s)
    end

    def derelative link
      return link unless link.relative?

      # YOLO: Addressable has a bug with its parsing heuristics
      # where a schemaless url is marked as relative. This isn't
      # a perfect bugfix however and is more of a hack and duct tape
      # https://github.com/sporkmonger/addressable/issues/265
      if link.scheme.nil? && link.to_s.start_with?("//")
        link.scheme = "https"
        return link
      end

      Addressable::URI.join(uri, link)
    end

    def client
      @client ||= HTTP.use(:auto_inflate).headers(headers).follow
    end

    def get uri:
      response = client.get uri

      errors.create key: uri, message: <<~MSG if response.status > 399
        Got non-okay status back from the server: #{ response.status }
      MSG

      # Without manually managing the temp file, there isn't an easy way to
      # breakup the following logic but I did my best and fuck you too rubocop
      binary_temp_file do |temp_file|
        write_body response: response, to: temp_file

        content_type = get_content_type(response:, io: temp_file)

        temp_file.rewind
        offline_cache.assets.attach(
          io: temp_file,
          filename: Digest::SHA256.hexdigest(uri.to_s),
          content_type:,
          metadata: build_metadata(response:)
        )
      end

      attachment = offline_cache.assets.order(:id).first

      [ response, attachment ]
    end

    def binary_temp_file
      Tempfile.create do |temp_file|
        temp_file.binmode

        yield temp_file
      end
    end

    # Streams the response body into the temp file to hopefully avoid some
    # memory issues if this is a large document
    def write_body response:, to:
      io_handle = to

      response.body.each do |partial|
        io_handle.write partial
      end

      io_handle.rewind
    end

    def build_metadata response:
      {
        uri: response.uri.to_s,
        status_code: response.code,
        headers: response.headers.to_h,
      }
    end

    def get_content_type response:, io:
      return response.content_type.mime_type if response.content_type.mime_type

      io_handle = io
      io_handle.rewind

      # some websites *cough*offline.pink*cough* don't return a content type
      # header, so we'll first see if the html doctype string is present and
      # guess this is text/html or we'll fallback to assuming its binary
      # https://en.wikipedia.org/wiki/Content_sniffing
      content_type ||= Marcel.by_magic(io_handle)
      content_type ||= "application/octet-stream"

      io_handle.rewind

      content_type
    end
  end
end
