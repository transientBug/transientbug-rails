module AutumnMoon
  # The brains of the operation
  #
  #  # In a cronjob
  #  bot = WeatherBot.new(chat: 789, user: 123)
  #  reply_obj = WeatherController.new(bot: bot).weather_check
  #  TelegramAdaptor.new(token: 456).send reply_obj

  #  # In a Webhook controller
  #  message_obj = TelegramAdaptor.new(token: 456).parse payload
  #  WeatherBot.dispatch message_obj
  #  TelegramAdaptor.send result

  #  # As a reciever loop
  #  TelegramAdaptor.new(token: 456).receive with_bot: WeatherBot
  class Bot
    class << self
      def dispatch message:
        new(message: message).dispatch
      end

      def router
        @router ||= AutumnMoon::Router.new
      end

      def route *args
        router.build_route(*args)
      end
    end

    attr_reader :session, :message, :chat, :user

    def initialize chat: nil, user: nil, message: nil
      @message = router.decompose message if message

      @chat = AutumnMoon::Chat.new(id: user) || message&.chat
      @user = AutumnMoon::User.new(id: user) || message&.user

      fail ArgumentError, "Chat required" unless @chat

      @session = AutumnMoon::Session.new chat: @chat, user: @user
    end

    def router
      self.class.router
    end

    def dispatch
      router.dispatch self
    end
  end
end
