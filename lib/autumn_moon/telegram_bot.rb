module AutumnMoon
  class TelegramBot < Bot
    class << self
      def [] token:
        method(:call).curry.call TelegramClient.new(token: token)
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

      def location *args
        route :location, nil, *args
      end

      def callback_query *args
        route :callback_query, nil, *args
      end

      def default *args
        route :all, "*", *args
      end

      def build_params_from payload:
        params = {}

        if payload[:callback_query]
          payload = payload[:callback_query]

          params = {
            verb: :callback_query,
            message_id: payload[:message][:message_id],
            chat_id: payload[:message][:chat][:id],
            user_id: payload[:from][:id],
            timestamp: Time.at(payload[:message][:date]),
            text: "",
            entities: [],
            metadata: {
              data: payload[:data],
              telegram: {
                user: payload[:from]
              }
            }
          }
        elsif payload.dig(:message, :location)
          payload = payload[:message]

          params = {
            verb: :location,
            message_id: payload[:message_id],
            chat_id: payload[:chat][:id],
            user_id: payload[:from][:id],
            timestamp: Time.at(payload[:date]),
            text: "",
            entities: [],
            metadata: {
              location: payload[:location],
              telegram: {
                user: payload[:from]
              }
            }

          }
        elsif payload[:message]
          payload = payload[:message]
          entities = payload.fetch(:entities, []).map do |entity|
            entity[:type] = entity[:type].to_sym
            entity[:text] = payload[:text][entity[:offset], entity[:length]]
            entity
          end.group_by { |entity| entity[:type] }

          params = {
            verb: :message,
            message_id: payload[:message_id],
            chat_id: payload[:chat][:id],
            user_id: payload[:from][:id],
            timestamp: Time.at(payload[:date]),
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

    def me
      @me ||= client.get_me
    end

    def bot_name
      me[:username]
    end

    def respond_with **options
      message = options.merge(
        chat_id: params[:chat_id]
      )

      Rails.logger.debug "Responding to chat #{ params[:chat_id] }, message #{ params[:message_id] }"

      res = client.send_message message

      session[:previous_message_id] = res[:message_id]

      res
    end

    def reply_with **options
      message = options.merge(
        chat_id: params[:chat_id],
        reply_to_message_id: params[:message_id]
      )

      Rails.logger.debug "Replying to message #{ params[:message_id] } in chat #{ params[:chat_id] }"

      res = client.send_message message

      session[:previous_message_id] = res[:message_id]

      res
    end

    def inline_reply_with **options
      message = options.merge(
        inline_query_id: params[:chat_id]
      )

      Rails.logger.debug "Replying to inline query #{ params[:chat_id] }"

      res = client.answer_inline_query message
      # binding.pry

      # session[:previous_message_id] = res[:message_id]

      res
    end

    def edit_message_reply_markup **options
      res = client.edit_message_reply_markup chat_id: params[:chat_id], message_id: params[:message_id], reply_markup: options
      # binding.pry

      # session[:previous_message_id] = res[:message_id]

      res
    end
  end
end
