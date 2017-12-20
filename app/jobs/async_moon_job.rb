class AsyncMoonJob < ApplicationJob
  queue_as :default

  def perform token, payload, adaptor=AutumnMoon::Telegram::Adaptor
    bot = AutumnMoon.bots[ token ]
    adaptor = adaptor.new token: token
    message = adaptor.parse payload.deep_symbolize_keys
    replies = bot.dispatch message: message
    replies.each { |reply| adaptor.send reply }
  end
end
