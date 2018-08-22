class Crowley
  BROWSABLE_MIMES = [
    "text/html",
    "application/xhtml+xml"
  ].freeze

  PARSABLE_MIMES = {
    "application/json" => ->(body) { JSON.parse body },
    "text/html" => ->(body) { Nokogiri::HTML body },
    "application/xhtml+xml" => ->(body) { Nokogiri::HTML body }
  }.freeze

  class Crawler
    extend Forwardable

    class << self
      attr_reader :url_pattern, :capybara_web_driver

      def name val=nil
        @name = val if val.present?
        @name
      end

      def handles_urls val
        fail "Needs to respond to #match?(String)" unless val.respond_to? :match?

        @url_pattern = val
      end

      def web_driver val=nil
        if val.present?
          fail "Needs to be a registered capybara driver!" unless Capybara.drivers.key? val
          @web_driver = val
        end

        @web_driver
      end

      def console url=nil
        return new.fetch url, handler: :console if url.present?

        new.console
      end

      def crawl url, handler: :crawl
        new.fetch url, handler: handler
      end
    end

    def_delegators :"self.class", :name, :url_pattern, :web_driver

    def browser
      @browser ||= Capybara::Session.new web_driver
    end

    def http
      @http ||= HTTP.follow
    end

    def fetch url, handler:, context: {}, verb: :get
      head_res = http.head url
      res_type = head_res.content_type.mime_type

      if BROWSABLE_MIMES.include? res_type
        browser.visit url
        current_body = browser.body
      else
        response = http.send verb, url
        current_body = response.body.to_s
      end

      current_body = PARSABLE_MIMES[ res_type ].call(current_body) if PARSABLE_MIMES.key?(res_type)
      current_url = Addressable::URI.parse(url)

      send handler, url: current_url, body: current_body, context: context
    end

    def console url: nil, body: nil, context: {}
      binding.pry
    end
  end
end
