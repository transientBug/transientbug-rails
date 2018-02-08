class WebpageCacheService
  class Render
    extend Forwardable

    attr_reader :offline_cache, :base_uri

    def initialize offline_cache:, base_uri:
      @offline_cache = offline_cache
      @base_uri = base_uri
    end

    def_delegator :@offline_cache, :webpage
    def_delegator :webpage, :uri

    def asset? key:
      find_attachment(key: key).present?
    end

    def asset key:
      StringIO.new find_attachment(key: key).blob.download
    end

    def content_type key:
      find_attachment(key: key).blob.content_type
    end

    def render
      rewrite_links!

      nokogiri.to_html
    end

    private

    def nokogiri
      @nokogiri ||= Nokogiri::HTML offline_cache.root.blob.download
    end

    def rewrite_links!
      ASSET_XPATHS.each do |xpath|
        nokogiri.xpath(xpath).each do |xpath_attr|
          xpath_attr.value = rewrite_link xpath_attr.value
        end
      end
    end

    def rewrite_link url
      link = uri + Addressable::URI.parse( url )
      link_key = Digest::SHA256.hexdigest link.to_s

      base_uri + link_key
    end

    def find_attachment key:
      offline_cache.assets.joins(:blob).find_by(active_storage_blobs: { filename: key })
    end
  end
end
