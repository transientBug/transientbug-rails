class CacheWebpageJob < ApplicationJob
  queue_as :default

  def perform bookmark:
  end
end

__END__

require "extraction_service"
require "fetch_service"

class ScrapeWebpageJob < ApplicationJob
  queue_as :default

  rescue_from FaradayMiddleware::RedirectLimitReached, Faraday::ConnectionFailed, Faraday::TimeoutError, URI::InvalidURIError do |exception|
    Rails.logger.error "Problem fetching #{ @webpage.parsed_uri.to_s } #{ exception }"
  end

  def perform(webpage:)
    @webpage = webpage

    if in_timeout?
      self.class.set(wait: (timeout + jitter).to_i).perform_later(webpage: @webpage)
      return
    else
      Redis.current.setex key, (30 + jitter).to_i, "true"
    end

    @webpage.scrapes.create(**extracted)
  end

  protected

  def key
   @key ||= [ "timeout", @webpage.parsed_uri.host ].join ":"
  end

  def timeout
    @timeout ||= Redis.current.ttl key
  end

  def jitter
    @jitter ||= (rand * 10)
  end

  def in_timeout?
    return false if timeout <= 0

    true
  end

  def scrape
    @scrape ||= FetchService.new(uri: @webpage.parsed_uri).fetch!
  end

  def extracted
    @extracted ||= ExtractionService.new(uri: @webpage.parsed_uri, body: scrape.body).extract!
  end
end
