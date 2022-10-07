# frozen_string_literal: true

class WebpageCacheService
  class Render
    extend Forwardable

    attr_reader :offline_cache, :base_uri

    def initialize offline_cache:, base_uri:
      @offline_cache = offline_cache
      @base_uri = base_uri
    end

    def_delegator :@offline_cache, :bookmark
    def_delegator :bookmark, :uri

    def asset? key:
      find_attachment(key:).present?
    end

    def asset key:
      StringIO.new find_attachment(key:).blob.download
    end

    def content_type key:
      find_attachment(key:).blob.content_type
    end

    def render
      if PARSABLE_MIMES.include?(offline_cache.root.content_type)
        rewrite_links!

        return [:html, nokogiri.to_html]
      end

      [:binary, offline_cache.root.content_type, offline_cache.root.blob.download]
    end

    private

    def nokogiri
      @nokogiri ||= Nokogiri::HTML offline_cache.root.blob.download
    end

    def rewrite_links!
      ASSET_XPATHS.each do |xpath|
        nokogiri.xpath(xpath).each do |xpath_attr|
          xpath_attr.value = rewrite_asset_link xpath_attr.value
        end
      end

      LINK_XPATHS.each do |xpath|
        nokogiri.xpath(xpath).each do |xpath_attr|
          xpath_attr.value = rewrite_link xpath_attr.value
        end
      end
    end

    def rewrite_asset_link url
      link = uri + Addressable::URI.parse( url )
      # TODO: This is no longer correct because the URL is getting morphed by
      # #links in Cache. I'll have to pass along the raw link as well as the
      # corrected on in order to make this work again
      link_key = Digest::SHA256.hexdigest link.to_s

      base_uri + link_key
    end

    def rewrite_link url
      Addressable::URI.join base_uri, url
    end

    def find_attachment key:
      offline_cache.assets.joins(:blob).find_by(active_storage_blobs: { filename: key })
    end
  end
end
