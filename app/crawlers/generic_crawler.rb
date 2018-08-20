Capybara.register_driver :firefox do |app|
  driver_options = Selenium::WebDriver::Firefox::Options.new

  driver_options.profile = Selenium::WebDriver::Firefox::Profile.new
  driver_options.profile["browser.link.open_newwindow"] = 3 # open windows in tabs
  driver_options.profile["media.peerconnection.enabled"] = false # disable web rtc

  Capybara::Selenium::Driver.new(app, browser: :firefox, options: driver_options)
end

Capybara.register_driver :firefox_headless do |app|
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
  web_driver :mechanize

  def crawl url:, body:, context: {}
  end
end
