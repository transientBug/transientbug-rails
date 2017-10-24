require "autumn_moon"
require "sample_bot"

AutumnMoon.register_bot ENV["BOT_TOKEN"], klass: SampleBot[token: ENV["BOT_TOKEN"]]
