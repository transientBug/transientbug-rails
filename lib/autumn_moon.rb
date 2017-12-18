module AutumnMoon
  VERSION = "v0.0.1".freeze

  class NoRouteMatchesError < NotImplementedError; end

  autoload :Bot,        "autumn_moon/bot"
  autoload :Adaptor,    "autumn_moon/bot"
  autoload :Chat,       "autumn_moon/bot"
  autoload :User,       "autumn_moon/bot"
  autoload :Message,    "autumn_moon/bot"
  autoload :Reply,      "autumn_moon/bot"
  autoload :Controller, "autumn_moon/bot"
  autoload :Decomposer, "autumn_moon/bot"
  autoload :Route,      "autumn_moon/bot"
  autoload :Router,     "autumn_moon/bot"
  autoload :Session,    "autumn_moon/bot"

  # Telegram specific classes
  autoload :TelegramClient, "autumn_moon/telegram_client"
  # autoload :TelegramAdaptor, "autumn_moon/telegram_bot"

  module_function

  def bots
    @bots ||= {}
  end

  def register_bot identifier, klass:
    bots[identifier] = klass
  end
end
