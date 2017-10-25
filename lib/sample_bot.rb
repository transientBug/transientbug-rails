require "autumn_moon"

module BotContext
  def self.registered klass
    # klass.set({})
    # klass.extend ClassMethods
    klass.prepend InstanceMethods
  end

  def self.route_added klass, pattern, method_name, conditions, options, route
    context = options[:context]
    return unless context

    unbound_method = klass.generate_unbound_method "unbound_condition" do
      session[:context] == context
    end

    route.conditions << unbound_method

    klass.before method_name do
      clear_context
    end
  end

  module InstanceMethods
    def clear_context
      session.delete :context
    end

    def set_context value
      session[:context] = value
    end
  end
end

class SampleBot < AutumnMoon::TelegramBot
  VERSION = "v0.0.0".freeze

  register AutumnMoon::Cache
  register BotContext

  route "/help", to: :testing_topic_help
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

  route "Commands", to: :help_commands, context: :help
  def help_commands
    body = <<~MSG
      Available commands:

      /help
    MSG

    respond_with text: body, reply_markup: { remove_keyboard: true }
  end

  route "About", to: :help_about, context: :help
  def help_about
    body = <<~MSG
      #{ bot_name } - #{ VERSION }
      AutumnMoon Framework - Version #{ AutumnMoon::VERSION }

      Author: @JoshAshby
    MSG

    respond_with text: body, reply_markup: { remove_keyboard: true }
  end

  route "*", to: :default_route
  def default_route
    respond_with text: "I'm sorry, I don't know what to say"
  end
end
