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

    def reply_with text: "", **opts
      replies << Reply.new(chat: bot.chat, user: bot.user, body: text, extra: opts)
    end

    alias_method :respond_with, :reply_with

    def process action
      # TODO before, around, after callbacks
      send action

      replies
    end
  end
end
