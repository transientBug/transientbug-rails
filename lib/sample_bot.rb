require "autumn_moon"

class SampleBot < AutumnMoon::TelegramBot
  VERSION = "v0.0.0".freeze

  register AutumnMoon::Cache
  register AutumnMoon::ContextRouter

  command "/help", to: :testing_topic_help
  def testing_topic_help
    set_context :help

    body = <<~MSG
      Please choose a topic for more information
    MSG

    respond_with text: body, reply_markup: {
      keyboard: [
        [
          "Commands"
        ],
        [
          "About"
        ]
      ],
      resize_keyboard: true,
      one_time_keyboard: true,
    }
  end

  message "Commands", to: :help_commands, context: :help
  def help_commands
    body = <<~MSG
      Available commands:

      /help
    MSG

    respond_with text: body, reply_markup: { remove_keyboard: true }
  end

  message "About", to: :help_about, context: :help
  def help_about
    body = <<~MSG
      #{ bot_name } - #{ VERSION }
      AutumnMoon Framework - Version #{ AutumnMoon::VERSION }

      Author: @JoshAshby
    MSG

    respond_with text: body, reply_markup: { remove_keyboard: true }
  end

  inline_query "*", to: :inline
  def inline
    inline_reply_with results: [
    ]
  end

  default to: :default_route
  def default_route
    reply_with text: "I'm sorry, I don't know what to say"
  end
end
