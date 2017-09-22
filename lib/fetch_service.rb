require "fetcher"

class FetchService
  attr_reader :uri, :response

  def initialize uri:
    @uri = uri
  end

  def fetch!
    @reponse ||= get
  end

  protected

  def connection
    @connection ||= Fetcher.new
  end

  def allowed?
    # TODO: Cache the robot parser
    robot_response = connection.get uri + "/robots.txt"
    body = robot_response.body || ""

    return true if robot_response.status == 404

    parser = Robotstxt.parse body, connection.user_agent

    parser.allowed? uri.to_s
  end

  def get
    return "" unless allowed?

    connection.get uri
  end
end
