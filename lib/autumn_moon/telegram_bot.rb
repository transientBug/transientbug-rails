module AutumnMoon
  class TelegramBot < Bot
    class << self
      def token
        @token ||= ""
      end

      def client
        @client ||= TelegramClient.new token: token
      end

      def me
        @me ||= {}
      end

      def [] token:
        @token = token
        @me = client.get_me
        self
      end
    end

    def client
      self.class.client
    end

    def bot_name
      self.class.me[:username]
    end

    def respond_with **options
      message = options.merge(
        chat_id: params[:chat][:id]
      )

      client.send_message message
    end

    def reply_with **options
      message = options.merge(
        chat_id: params[:chat][:id],
        reply_to_message_id: params[:message_id]
      )

      client.send_message message
    end

    # def answer_inline_query results, params:{}
    # end

    # def answer_callback_query text, params: {}
    # end

    # def edit_message type, params: {}
    # end
  end
end
