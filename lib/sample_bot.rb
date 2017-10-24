require "autumn_moon"

class SampleBot < AutumnMoon::TelegramBot
  handle "/help :topic", to: :topic_help
  default to: :help

  def topic_help
    binding.pry
  end

  def help
    reply_with text: "#{ bot_name }: v0.0.0"
  end
end
