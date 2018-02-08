require "tempfile"

class WebpageCacheService
  class Cache
    extend Forwardable

    attr_reader :offline_cache

    def initialize webpage:
      @webpage = webpage
      @offline_cache = webpage.offline_caches.create
    end

    def_delegator :@webpage, :uri

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

    def exec
      cache

      # Return self since there is an errors object and the offline cache model
      # that people might care about on this object.
      self
    end

    private

    # rubocop:disable Metrics/AbcSize
    def cache
      response, root_attachment = get uri: uri
      @root_attachment = root_attachment

      offline_cache.tap do |obj|
        obj.root = @root_attachment
        obj.save
      end

      if response.status > 399
        errors.add uri, "Got non-okay status back from the server: #{ response.status }"
        return
      end

      return unless PARSABLE_MIMES.include? root_attachment.blob.content_type

      links.each { |link| get uri: link }
    end
    # rubocop:enable Metrics/AbcSize

    # this has some serious memory implications since it reads the whole file
    # in, but hopefully people don't have gigabyte sized HTML pages
    def nokogiri
      @nokogiri ||= Nokogiri::HTML(@root_attachment.blob.download)
    end

    def links
      @links ||= ASSET_XPATHS.flat_map(&nokogiri.method(:xpath))
        .map(&:to_s)
        .map(&Addressable::URI.method(:parse))
        .map { |link| uri + link }
    end

    def client
      @client ||= HTTP.headers(headers).follow
    end

    # rubocop:disable Metrics/AbcSize
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

        unless content_type
          # some websites *cough*offline.pink*cough* don't return a content type
          # header, so we'll first see if the html doctype string is present and
          # guess this is text/html or we'll fallback to assuming its binary
          # https://en.wikipedia.org/wiki/Content_sniffing
          content_type ||= MimeMagic.by_magic(temp_file)
          content_type ||= "application/octet-stream"

          temp_file.rewind
        end

        offline_cache.assets.attach(
          io: temp_file,
          filename: Digest::SHA256.hexdigest(uri.to_s),
          content_type: content_type,
          metadata: {
            uri: uri.to_s,
            status_code: response.code,
            headers: response.headers.to_h
          }
        )&.first
      end

      [ response, attachment ]
    end
    # rubocop:enable Metrics/AbcSize
  end
end
