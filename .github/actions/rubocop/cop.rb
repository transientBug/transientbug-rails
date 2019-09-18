require "net/http"
require "json"
require "time"
require "ostruct"

class Client
  attr_reader :token

  def initialize token:
    @token = token
  end

  def get url
    handle_response client.get(url, headers)
  end

  def post url, body
    handle_response client.post(url, body, headers)
  end

  def patch url, body
    handle_response client.patch(url, body, headers)
  end

  def delete url
    handle_response client.delete(url, headers)
  end

  def build_payload &block
    OpenStruct.new(name: "TB Rubocop").tap(&block).to_h.to_json
  end

  protected

  def headers
    @headers ||= {
      "Content-Type": "application/json",
      "Accept": "application/vnd.github.antiope-preview+json",
      "Authorization": "Bearer #{ token }",
      "User-Agent": "rubocop-action"
    }
  end

  def client
    @client ||= Net::HTTP.new("api.github.com", 443).tap do |http|
      http.use_ssl = true
    end
  end

  def handle_response response
    fail "#{ response.message } - #{ response.body }" if response.code.to_i >= 300

    JSON.parse response.body
  end
end

class Check
  attr_reader :id

  def initialize client:, sha:, repo:
    @client = client
    @sha = sha
    @repo = repo
    @status = :unstarted
  end

  def start!
    fail "Can not start an already started check!" if @status == :started
    fail "Can not start an already finished check!" if @status == :finished

    payload = @client.build_payload do |hash|
      hash.head_sha = @sha
      hash.status = :in_progress
      hash.started_at = Time.now.iso8601
    end

    @id = @client.post("/repos/#{ @repo }/check-runs", payload).fetch "id"

    @status = :started

    id
  end

  def finish! conclusion:, output: nil
    fail "Can not finish unstarted check!" if @status == :unstarted
    fail "Can not finish an already finished check!" if @status == :finished

    payload = @client.build_payload do |hash|
      hash.head_sha = @sha
      hash.status = :completed
      hash.completed_at = Time.now.iso8601
      hash.conclusion = conclusion
      hash.output = output if output
    end

    res = @client.patch "/repos/#{ @repo }/check-runs/#{ id }", payload

    @status = :finished

    res
  end
end

def run_rubocop
  `rubocop --format json`.yield_self(&JSON.method(:parse))
end

def process_annotations result
  annotation_levels = {
    "refactor" => :failure,
    "convention" => :failure,
    "warning" => :warning,
    "error" => :failure,
    "fatal" => :failure
  }

  result["files"].flat_map do |file|
    path = file["path"]

    file["offenses"].map do |offense|
      severity = offense["severity"]
      message = offense["message"]
      location = offense["location"]

      {
        path: path,
        start_line: location["start_line"],
        end_line: location["last_line"],
        annotation_level: annotation_levels[severity],
        message: message
      }
    end
  end
end

def run
  event = File.read(ENV["GITHUB_EVENT_PATH"]).yield_self(&JSON.method(:parse))

  owner = event.dig "repository", "owner", "login"
  repo = event.dig "repository", "name"

  client = Client.new token: ENV["GITHUB_TOKEN"]
  check = Check.new client: client, sha: ENV["GITHUB_SHA"], repo: "#{ owner }/#{ repo }"
  check.start!

  annotations = Dir.chdir(ENV["GITHUB_WORKSPACE"]) { run_rubocop }.yield_self(&method(:process_annotations))

  payload = {
    conclusion: annotations.any? ? :failure : :success,
    output: {
      title: "tb Rubocop",
      summary: "#{ annotations.count } offense(s) found",
      annotations: annotations
    }
  }

  check.finish!(**payload)

  fail if annotations.any?
rescue => e
  puts e
  check.finish! conclusion: :failure
  fail
end

run()
