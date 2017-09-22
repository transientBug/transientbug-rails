require "faraday_middleware/response/follow_redirects"

class Fetcher
  extend Forwardable

  attr_reader :connection, :user_agent

  def initialize connection: nil, user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:57.0) Gecko/20100101 Firefox/57.0"
    @user_agent = user_agent

    @connection ||= connection
    @connection ||= Faraday.new(headers: {
      "Accept-Language" => "en-US,en;q=0.5",
      "User-Agent" => @user_agent,
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8; charset=utf-8"
    }) do |builder|
      builder.use Faraday::Response::Logger, Rails.logger
      builder.use FaradayMiddleware::FollowRedirects, limit: 3

      # builder.adapter Faraday.default_adapter
      builder.adapter :excon
    end
  end

  def_delegators :connection, :get, :post, :put, :delete, :patch, :head, :options
end
