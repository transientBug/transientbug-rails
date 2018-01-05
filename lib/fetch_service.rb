class FetchService
  attr_reader :uri, :response

  def initialize uri:
    fail ArgumentError, "Expected a uri of type Addressable::URI, got `#{ uri.class }' instead" unless uri.is_a? Addressable::URI

    @uri = uri
  end

  def call
    @response = client.get uri
  end

  protected

  def client
    @client ||= HTTP.headers(
      user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:57.0) Gecko/20100101 Firefox/57.0",
      accept_language: "en-US,en;q=0.5",
      accept: "application/html;q=0.9,*/*;q=0.8; charset=utf-8"
    )
  end

  def allowed?
    # TODO: Cache the robot parser
    robot_response = client.get uri + "/robots.txt"
    body = robot_response.body || ""

    return true if robot_response.status == 404

    parser = Robotstxt.parse body, connection.user_agent

    parser.allowed? uri.to_s
  end
end
