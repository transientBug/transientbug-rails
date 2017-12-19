class TransientBugBot
  class BaseController < AutumnMoon::Controller
    include AutumnMoon::ContextDecomposer::ControllerMethods
    include AutumnMoon::Telegram::ControllerMethods

    def start
      respond_with text: "Hia!"
    end

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
        one_time_keyboard: true
      }
    end

    def help_commands
      body = <<~MSG
        Available commands:

      MSG

      bot.router.routes
        .select { |route|  route.options[:doc].present? }
        .each do |route|
          body += "#{ route.raw_pattern } - #{ route.options[:doc] }\n"
        end

      respond_with text: body, reply_markup: { remove_keyboard: true }
    end

    def help_about
      body = <<~MSG
        Version: #{ TransientBugBot::VERSION }
        AutumnMoon Ruby Bot Framework - Version: #{ AutumnMoon::VERSION }

        Author: @JoshAshby
      MSG

      respond_with text: body, reply_markup: { remove_keyboard: true }
    end

    def default_route
      reply_with text: "I'm sorry, I don't know what to say"
    end
  end
end
