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
        Class.new self do
          @token = token
        end
      end

      def command *args
        route :command, *args
      end

      def message *args
        route :message, *args
      end

      def inline_query *args
        route :inline_query, *args
      end

      def default *args
        route :all, "*", *args
      end

      def build_params_from payload:
        params = {}

        if payload[:message]
          payload = payload[:message]
          entities = payload.fetch(:entities, []).map do |entity|
            entity[:type] = entity[:type].to_sym
            entity[:text] = payload[:text][entity[:offset], entity[:length]]
            entity
          end.group_by { |entity| entity[:type] }

          timestamp = Time.at payload[:date]

          params = {
            verb: :message,
            message_id: payload[:message_id],
            chat_id: payload[:chat][:id],
            user_id: payload[:from][:id],
            timestamp: timestamp,
            text: payload[:text],
            entities: entities,
            metadata: {
              telegram: {
                user: payload[:from]
              }
            }
          }

          if entities[:bot_command]
            params[:metadata][:command] = entities[:bot_command].min { |c| c[:offset] }[:text]
            params[:verb] = :command
          end
        elsif payload[:inline_query]
          payload = payload[:inline_query]

          params = {
            verb: :inline_query,
            message_id: payload[:id],
            chat_id: payload[:id],
            user_id: payload[:from][:id],
            timestamp: Time.current,
            text: payload[:query],
            entities: [],
            metadata: {
              telegram: {}
            }
          }
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
        chat_id: params[:chat_id]
      )

      Rails.logger.debug "Responding to chat #{ params[:chat_id] }, message #{ params[:message_id] }"

      client.send_message message
    end

    def reply_with **options
      message = options.merge(
        chat_id: params[:chat_id],
        reply_to_message_id: params[:message_id]
      )

      Rails.logger.debug "Replying to message #{ params[:message_id] } in chat #{ params[:chat_id] }"

      client.send_message message
    end

    def inline_reply_with **options
      message = options.merge(
        inline_query_id: params[:chat_id]
      )

      Rails.logger.debug "Replying to inline query #{ params[:chat_id] }"

      client.answer_inline_query message
    end

    # def answer_callback_query text, params: {}
    # end

    # def edit_message type, params: {}
    # end
  end
end
