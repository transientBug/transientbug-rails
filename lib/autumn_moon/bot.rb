module AutumnMoon
  class Adaptor
    def initialize *data
      @args = data
    end

    def send reply_obj
      fail NotImplementedError
    end

    def parse raw_payload
      #fail NotImplementedError

      chat_obj = Chat.new id: raw_payload[:chat][:id]
      user_obj = User.new id: raw_payload[:user][:id]

      message_obj = Message.new text: raw_payload[:text], chat: chat_obj, user: user_obj

      message_obj
    end

    def receive with_bot:
      fail NotImplementedError

      payload = fetch
      message_obj = parse payload
      with_bot.dispatch message_obj
      send result
    end
  end

  class Chat
    attr_reader :id

    def initialize id:
      @id = id
    end
  end

  class User
    attr_reader :id

    def initialize id:
      @id = id
    end
  end

  class Message
    attr_reader :chat, :user, :body

    attr_accessor :decompositions

    def initialize chat:, user: nil, body:
      @chat = chat
      @user = user
      @body = body
    end

    def decompositions
      @decompositions ||= {}
    end

    def intent
      @decompositions[:IntentDecomposer]
    end
  end

  class Reply
    attr_reader :chat, :user, :body

    def initialize chat:, user: nil, body:
      @chat = chat
      @user = user
      @body = body
    end
  end

  class Controller
    attr_reader :session

    def initialize session:
      @session = session
    end
  end

  class Decomposer
    def self.call message_obj
      new(message: message_obj).call
    end

    attr_reader :message

    def initialize message:
      @message = message
    end

    def call
      result = handle
      message.decompositions[ self.class.name.to_sym ] = result
      message
    end

    def handle
      fail NotImplementedError
    end
  end

  class IntentDecomposer
    def handle
      return :command if message.body.match?(%r{^/.*})
    end
  end

  class Router
    attr_reader :routes, :decomposers

    def initialize
      @routes = []
      @decomposers = [
        IntentDecomposer
      ]
    end

    def dispatch message:
      decomposed_message_obj = decomposers.each_with_object(message) do |decomposer, memo|
        decomposer.call memo
      end

      routes.find { |route| route.match? decomposed_message_obj }.call decomposed_message_obj
    end

    def dispatch_action action:
      routes.find { |route| route.action == action }.call
    end
  end

  class Route
  end

  class Bot
    class << self
      def with_session_for chat: nil, user: nil, message: nil
        session = Session.new chat: message.chat, user: message.user if message

        fail "Chat required" unless chat

        session ||= Session.new bot: self, chat: chat, user: user

        new(session: session, message: message)
      end

      def dispatch message:
        instance = with_session_for message: message
        router.dispatch message: message, instance: instance
      end

      def router
        @router ||= Router.new
      end
    end

    attr_reader :session, :message

    def initialize session:, message:
      @session = session
      @message = message
    end

    def router
      self.class.router
    end

    def run_action action_name
      result = router.dispatch_action action: action_name

      session.persist

      result
    end
  end

  class Session
    attr_reader :bot, :chat, :user

    def initialize bot:, chat:, user: nil
      @bot = bot
      @chat = chat
      @user = user

      load!
    end

    def load!
      @session = {}
    end

    def persist!
    end
  end
end

__END__
# In a cronjob
TelegramAdaptor.new(token: 456).send WeatherBot.with_session_for(chat: 789, user: 123).run_action(:say_weather)

# In a Webhook controller
message_obj = TelegramAdaptor.new(token: 456).parse payload
WeatherBot.dispatch message_obj
TelegramAdaptor.send result

# As a reciever loop
TelegramAdaptor.new(token: 456).receive with_bot: WeatherBot
