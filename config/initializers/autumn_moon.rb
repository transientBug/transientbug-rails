require "autumn_moon"
require "sample_bot"

Rails.application.credentials.bot_tokens.each do |name, token|
  AutumnMoon.register_bot token, klass: SampleBot[token: token]
end
