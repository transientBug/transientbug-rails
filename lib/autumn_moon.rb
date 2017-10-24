module AutumnMoon
  autoload :Bot, "autumn_moon/bot"

  autoload :ShadowRidge, "autumn_moon/shadow_ridge"
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
