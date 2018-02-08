class WebpageCacheService
  class Render
    extend Forwardable

    attr_reader :offline_cache

    def initialize offline_cache:
      @offline_cache = offline_cache
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

    def render base_uri:
      nokogiri = Nokogiri::HTML(offline_cache.root.blob.download)

      ASSET_XPATHS.each do |xpath|
        nokogiri.xpath(xpath).each do |xpath_attr|
          link = uri + Addressable::URI.parse(xpath_attr.value)
          link_key = Digest::SHA256.hexdigest(link.to_s)

          xpath_attr.value = base_uri + link_key
        end
      end

      nokogiri.to_html
    end

    private

    def find_attachment key:
      offline_cache.assets.joins(:blob).find_by(active_storage_blobs: { filename: key })
    end
  end
end
