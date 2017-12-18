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

      # payload = fetch
      # message_obj = parse payload
      # with_bot.dispatch message_obj
      # send result
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
    attr_reader :chat, :user, :body, :decompositions

    def initialize chat:, user: nil, body:
      @chat = chat
      @user = user
      @body = body
    end

    def decompositions
      @decompositions ||= {}
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
    attr_reader :bot

    def initialize bot:
      @bot = bot
    end

    def session
      bot.session
    end

    def message
      bot.message
    end
  end

  class Decomposer
    def modify_route route
      route
    end

    def call message:
      message.decompositions[ self.class.name.to_sym ] = handle_message message
      message
    end

    def handle_message message; end
  end

  class Route
    attr_reader :on_conditions, :options

    def initialize pattern=nil, to:, on: [], **opts
      @pattern = pattern

      @to_controller = to
      @on_conditions = Array(on)

      @options = opts
    end

    def match? bot
      # TODO
      false
    end

    def call bot
    end
  end

  class Router
    attr_reader :routes, :decomposers

    def initialize
      @routes = []
      @decomposers = []
    end

    def add_decomposer decomposer
      @decomposers << decomposer.new
    end

    def build_route *args
      routes << decomposers.each_with_object(Route.new(*args)) do |decomposer, memo|
        decomposer.modify_route memo
      end
    end

    def decompose message
      decomposers.each_with_object(message) do |decomposer, memo|
        decomposer.call memo
      end
    end

    def dispatch bot_instance
      found_route = routes.find { |route| route.match? bot_instance }

      fail NoRouteMatchesError unless found_route

      found_route.call bot_instance
    end
  end

  class Session
    attr_reader :bot, :chat, :user

    def initialize chat:, user: nil
      @chat = chat
      @user = user

      @data = {}
    end

    def [] key
      @data[key]
    end

    def []= key, value
      @data[key] = value
    end
  end

  class Bot
    class << self
      def dispatch message:
        new(message: message).dispatch
      end

      def router
        @router ||= Router.new
      end

      def route *args
        router.build_route(*args)
      end
    end

    attr_reader :session, :message

    def initialize chat: nil, user: nil, message: nil
      message = router.decompose message if message

      @session = session_for chat: chat, user: user, message: message
      @message = message
    end

    def router
      self.class.router
    end

    def dispatch
      router.dispatch self
    end

    def session_for chat: nil, user: nil, message: nil
      chat ||= message.chat
      user ||= message.user

      fail "Chat required" unless chat

      Session.new chat: chat, user: user
    end
  end
end

__END__
# In a cronjob
bot = WeatherBot.new(chat: 789, user: 123)
reply_obj = WeatherController.new(bot: bot).weather_check
TelegramAdaptor.new(token: 456).send reply_obj

# In a Webhook controller
message_obj = TelegramAdaptor.new(token: 456).parse payload
WeatherBot.dispatch message_obj
TelegramAdaptor.send result

# As a reciever loop
TelegramAdaptor.new(token: 456).receive with_bot: WeatherBot
