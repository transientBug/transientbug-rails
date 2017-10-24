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
        @me ||= client.get_me
      end

      def [] token:
        @token = token
        self
      end

      def build_params_from payload:
        entities = payload.fetch(:entities, []).map do |entity|
          entity[:type] = entity[:type].to_sym
          entity[:text] = payload[:text][entity[:offset], entity[:length]]
          entity
        end.group_by { |entity| entity[:type] }

        timestamp = Time.at payload[:date]

        params = {
          entities: entities,
          text: payload[:text],
          timestamp: timestamp
        }.merge(payload.slice(:message_id, :from, :chat))

        if entities[:bot_command]
          params[:command] = entities[:bot_command].min { |c| c[:offset] }[:text]
        end

        params
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
