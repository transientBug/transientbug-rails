require "autumn_moon"
require "sample_bot"

Rails.application.config_for(:autumn_moon).deep_symbolize_keys.each do |name, data|
  AutumnMoon.register_bot data[:token], klass: data[:klass].constantize[token: data[:token]]
end
