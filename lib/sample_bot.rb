require "autumn_moon"

class SampleBot < AutumnMoon::TelegramBot
  VERSION = "v0.0.0".freeze

  route "/help", to: :testing_topic_help, on: [ ->{ session[:context] == nil } ]
  def testing_topic_help
    body = <<~MSG
      Please choose an topic for more information
    MSG

    reply_with text: body, reply_markup: {
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

    session[:context] = :help
  end

  route "Commands", to: :help_commands, on: [ ->{ session[:context] == :help } ]
  def help_commands
    session.delete :context

    body = <<~MSG
      Available commands:

      /help
    MSG

    reply_with text: body, reply_markup: { remove_keyboard: true }
  end

  route "About", to: :help_about, on: [ ->{ session[:context] == :help } ]
  def help_about
    session.delete :context

    body = <<~MSG
      #{ bot_name } - #{ VERSION }
      AutumnMoon Framework - Version #{ AutumnMoon::VERSION }

      Author: @JoshAshby
    MSG

    reply_with text: body, reply_markup: { remove_keyboard: true }
  end

  route "*", to: :default_route
  def default_route
    reply_with text: "I'm sorry, I don't know what to say"
  end
end
