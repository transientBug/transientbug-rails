# Be sure to restart your server when you modify this file.
# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

# Rails.application.config.content_security_policy do |policy|
#   policy.default_src :self, :https
#   policy.font_src    :self, :https, :data
#   policy.img_src     :self, :https, :data
#   policy.object_src  :none
#   policy.script_src  :self, :https
#   policy.style_src   :self, :https
#   # If you are using webpack-dev-server then specify webpack-dev-server host
#   policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?

#   # Specify URI for violation reports
#   # policy.report_uri "/csp-violation-report-endpoint"
# end

Rails.application.config.content_security_policy do |policy|
  policy.default_src     :self, :https
  policy.font_src        :self, :https, :data
  policy.img_src         :self, :https, :data
  policy.object_src      :none
  policy.script_src      :self, :https
  policy.style_src       :self, :https
  policy.frame_ancestors :self, :https

  if Rails.env.development?
    policy.default_src     :self, :https, "http://localhost:*", "ws://localhost:*", "http://localhost:8080"
    policy.script_src      :self, :https, "http://localhost:*", "http://0.0.0.0:*", :unsafe_eval, :unsafe_inline
    policy.connect_src     :self, :https, "http://localhost:3035", "ws://localhost:3035"
    policy.style_src       :self, :https, "http://localhost:*", "http://0.0.0.0:*", :unsafe_inline
    policy.frame_ancestors :self, :https, "http://localhost:*", "http://0.0.0.0:*"
  end

  # Specify URI for violation reports
  policy.report_uri  "/csp-violation-report"
end

# If you are using UJS then enable automatic nonce generation
unless Rails.env.development?
  Rails.application.config.content_security_policy_nonce_generator = -> request do
    if request.env['HTTP_TURBOLINKS_REFERRER'].present?
      request.env['HTTP_X_TURBOLINKS_NONCE']
    else
      SecureRandom.base64(16)
    end
  end
end
# Set the nonce only to specific directives
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src)

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true
