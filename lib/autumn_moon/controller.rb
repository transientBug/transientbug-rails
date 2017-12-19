module AutumnMoon
  class Controller
    attr_reader :bot, :replies

    def initialize bot:
      @bot = bot
      @replies = []
    end

    def session
      bot.session
    end

    def message
      bot.message
    end

    def build_reply text:, extra:
      replies << Reply.new(chat: bot.chat, user: bot.user, message: message, body: text, extra: extra)
    end

    def process action
      # TODO before, around, after callbacks
      send action

      replies
    end
  end
end
