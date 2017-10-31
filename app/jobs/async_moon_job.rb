class AsyncMoonJob < ApplicationJob
  queue_as :default

  def perform token, payload
    bot = AutumnMoon.bots[ token ]
    bot.call payload.deep_symbolize_keys
  end
end
