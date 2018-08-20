class Crowley
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

      def console url: nil
        return new.fetch url, handler: :console if url.present?

        new.console
      end

      def crawl url, handler: :crawl
        new.fetch url, handler: handler
      end
    end

    def_delegators :"self.class", :name, :url_pattern, :web_driver

    def browser
      @browser ||= Capybara::Session.new(web_driver)
    end

    def fetch url, handler:, context: {}
      browser.visit url

      current_body = Nokogiri::HTML(browser.body)

      send handler, url: url, body: current_body, context: context
    end

    def console url: nil, body: nil, context: {}
      binding.pry
    end
  end
end
