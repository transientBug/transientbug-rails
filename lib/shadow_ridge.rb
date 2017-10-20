class ShadowRidge
  extend Forwardable

  attr_reader :client

  def initialize user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:57.0) Gecko/20100101 Firefox/57.0"
    headers = {
      user_agent: @user_agent,
      accept_language: "en-US,en;q=0.5",
      accept: "application/json;q=0.9,*/*;q=0.8; charset=utf-8"
    }

    @client = HTTP.follow.headers(headers)
  end

  def_delegators :client, :get, :post, :put, :delete, :patch, :head, :options
end
