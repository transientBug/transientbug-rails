module AutumnMoon
  VERSION = "v0.0.1".freeze

  autoload :Bot, "autumn_moon/bot"
  autoload :Cache, "autumn_moon/cache"
  autoload :ContextRouter, "autumn_moon/context_router"

  # Telegram specific classes
  autoload :TelegramClient, "autumn_moon/telegram_client"
  autoload :TelegramBot, "autumn_moon/telegram_bot"

  module_function

  def bots
    @bots ||= {}
  end

  def register_bot identifier, klass:
    bots[identifier] = klass
  end
end
