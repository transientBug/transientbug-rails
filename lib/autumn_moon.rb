module AutumnMoon
  VERSION = "v0.0.1".freeze

  class NoRouteMatchesError < NotImplementedError; end

  autoload :Bot,        "autumn_moon/bot"
  autoload :Adaptor,    "autumn_moon/adaptor"
  autoload :Chat,       "autumn_moon/chat"
  autoload :User,       "autumn_moon/user"
  autoload :Message,    "autumn_moon/message"
  autoload :Reply,      "autumn_moon/reply"
  autoload :Controller, "autumn_moon/controller"
  autoload :Decomposer, "autumn_moon/decomposer"
  autoload :Route,      "autumn_moon/route"
  autoload :Router,     "autumn_moon/router"
  autoload :Session,    "autumn_moon/session"

  # Telegram specific classes
  autoload :Telegram, "autumn_moon/telegram"

  module_function

  def bots
    @bots ||= {}
  end

  def register_bot identifier, klass:
    bots[identifier] = klass
  end
end
