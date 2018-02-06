class WebpageCacheService
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
      metadata["links"][ key ]["content_type"]
    end

    def asset? key:
      root.join("assets", key).exist?
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
