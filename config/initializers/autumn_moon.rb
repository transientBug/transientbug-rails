require "autumn_moon"
require "transient_bug_bot"

Rails.application.config_for(:autumn_moon).deep_symbolize_keys.each do |name, data|
  AutumnMoon.register_bot data[:token], klass: data[:klass].constantize
end
