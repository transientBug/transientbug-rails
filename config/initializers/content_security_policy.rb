Rails.application.config.content_security_policy do |p|
  p.default_src :self, :https
  p.font_src    :self, :https, :data, "fonts.gstatic.com"
  p.img_src     :self, :https, :data
  p.object_src  :none
  p.script_src  :self, :https, :unsafe_inline
  p.style_src   :self, :https, :unsafe_inline, "fonts.googleapis.com"

  # Specify URI for violation reports
  # p.report_uri  "/csp-violation-report-endpoint"
end