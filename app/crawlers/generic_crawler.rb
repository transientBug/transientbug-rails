Capybara.register_driver :selenium_firefox do |app|
  driver_options = Selenium::WebDriver::Firefox::Options.new

  driver_options.profile = Selenium::WebDriver::Firefox::Profile.new
  driver_options.profile["browser.link.open_newwindow"] = 3 # open windows in tabs
  driver_options.profile["media.peerconnection.enabled"] = false # disable web rtc

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: driver_options)
end

Capybara.register_driver :selenium_firefox_headless do |app|
  driver_options = Selenium::WebDriver::Firefox::Options.new

  driver_options.add_argument "-headless"

  driver_options.profile = Selenium::WebDriver::Firefox::Profile.new
  driver_options.profile["browser.link.open_newwindow"] = 3 # open windows in tabs
  driver_options.profile["media.peerconnection.enabled"] = false # disable web rtc

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: driver_options)
end

class GenericCrawler < Crowley::Crawler
  name "Generic Crawler"

  handles_urls %r{.*} # something that responds to #match?(String)
  web_driver :selenium_firefox

  FAVICON_XPATH = '//link[@rel="shortcut icon"]'.freeze

  ASSET_XPATHS = [
    "//link[@rel='stylesheet']/@href",
    "//script/@src",
    "//img/@src"
  ].freeze

  LINK_XPATHS = [
    "//a/@href"
  ].freeze

  def crawl url:, body:, context: {}
    favicon = favicon_for body, root: url

    binding.pry
  end

  def favicon_for body, root:
    favicon_urls ||= []

    if body.is_a? Nokogiri::HTML
      favicon_urls = body.xpath(FAVICON_XPATH)
        .map(&:to_s)
        .uniq
        .compact
        .map(&Addressable::URI.method(:parse))
        .map { |link| root + link }
    end

    favicon_urls.unshift root + "/favicon.ico"

    favicon_urls.map(&method(:fetch_favicon)).compact.first
  end

  def fetch_favicon url
    response = http.get url

    return if !response.status.success?

    Base64.encode64(response.body.to_s)
  end
end
