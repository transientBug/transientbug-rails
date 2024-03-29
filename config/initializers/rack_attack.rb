Rack::Attack.enabled = false if Rails.env.development? || Rails.env.test?

class Rack::Attack

  ### Configure Cache ###

  # If you don't want to use Rails.cache (Rack::Attack's default), then
  # configure it here.
  #
  # Note: The store is only used for throttling (not blocklisting and
  # safelisting). It must implement .increment and .write like
  # ActiveSupport::Cache::Store

  # Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # Screw this one person in particular
  blocklist_ip("34.83.207.109")

  # This could use some better setup but these are the common paths I see a lot
  # getting tried, so let's start with temp banning them for now. The maxretry,
  # findtime and bantime could use some better adjusting and is a bit egregious
  # right now but thats okay
  blocklist("fail2ban") do |req|
    # Rack::Attack::Fail2Ban.filter("pentesters-#{ req.ip }", maxretry: 2, findtime: 1.hour, bantime: 12.hours) do
      # The count for the IP is incremented if the return value is truthy
      is_bad = CGI.unescape(req.query_string) =~ %r{/etc/passwd}

      is_bad ||= req.path.include?("/etc/passwd")
      is_bad ||= req.path.include?(".git")
      is_bad ||= req.path.include?(".env")
      is_bad ||= req.path.include?("/_")
      is_bad ||= req.path.include?("/owa")
      is_bad ||= req.path.include?("/vpns/")
      is_bad ||= req.path.include?("/cgi-bin/")
      is_bad ||= req.path.include?("/script/")
      is_bad ||= req.path.include?("/jenkins/")
      is_bad ||= req.path.include?("wp-")
      is_bad ||= req.path.include?("php")
      is_bad ||= req.path.include?("aspx")

      is_bad ||= req.env["HTTP_ACCEPT"]&.include?("../")
      is_bad ||= req.env["HTTP_ACCEPT"]&.include?("com.")
      is_bad ||= req.env["HTTP_ACCEPT"]&.include?("jndi")

      is_bad ||= req.request_method =~ %r{PRI}

      is_bad
    # end
  end

  ### Throttle Spammy Clients ###

  # If any single client IP is making tons of requests, then they're
  # probably malicious or a poorly-configured scraper. Either way, they
  # don't deserve to hog all of the app server's CPU. Cut them off!
  #
  # Note: If you're serving assets through rack, those requests may be
  # counted by rack-attack and this throttle may be activated too
  # quickly. If so, enable the condition to exclude them from tracking.

  # Throttle all requests by IP (60rpm)
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/csp-violation-report") && req.post?
  end

  ### Prevent Brute-Force Login Attacks ###

  # The most common brute-force login attack is a brute-force password
  # attack where an attacker simply tries a large number of emails and
  # passwords to see if any credentials match.
  #
  # Another common method of attack is to use a swarm of computers with
  # different IPs to try brute-forcing a password for a specific account.

  # Throttle POST requests to /login by IP address
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/ip:#{req.ip}"
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/login" && req.post?
      req.ip
    end
  end

  # Throttle POST requests to /login by email param
  #
  # Key: "rack::attack:#{Time.now.to_i/:period}:logins/email:#{req.email}"
  #
  # Note: This creates a problem where a malicious user could intentionally
  # throttle logins for another user and force their login requests to be
  # denied, but that's not very common and shouldn't happen to you. (Knock
  # on wood!)
  throttle("logins/email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/login" && req.post?
      # return the email if present, nil otherwise
      req.params["email"].presence
    end
  end

  ### Custom Throttle Response ###

  # By default, Rack::Attack returns an HTTP 429 for throttled responses,
  # which is just fine.
  #
  # If you want to return 503 so that the attacker might be fooled into
  # believing that they've successfully broken your app (or you just want to
  # customize the response), then uncomment these lines.
  # self.throttled_response = lambda do |env|
  #  [ 503,  # status
  #    {},   # headers
  #    ['']] # body
  # end
end
