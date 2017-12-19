module AutumnMoon
  module Telegram
    class Adaptor < AutumnMoon::Adaptor
      def client
        @client ||= AutumnMoon::Telegram::Client.new token: options[:token]
      end

      def send reply_obj
        Rails.logger.debug "Replying to message ID #{ reply_obj.message.id } with intent #{ reply_obj.extra[:intent] }"

        case reply_obj.extra[:intent]
        when :respond
          message = {
            chat_id: reply_obj.chat.id,
            text: reply_obj.body
          }.merge reply_obj.extra[:telegram]

          client.send_message message
        when :reply
          {
            chat_id: reply_obj.chat.id,
            reply_to_message_id: reply_obj.message.id,
            text: reply_obj.body
          }.merge reply_obj.extra[:telegram]

          client.send_message message
        when :inline_reply
          message = {
            inline_query_id: reply_obj.message.id,
            results: reply_obj.extra[:inline_reply]
          }.merge reply_obj.extra[:telegram]

          client.answer_inline_query message
        when :edit_markup
          message = {
            chat_id: reply_obj.chat.id,
            message_id: reply_obj.message.id,
            reply_markup: { inline_keyboard: reply_obj.extra[:edit_markup] }
          }.merge reply_obj.extra[:telegram]

          client.edit_message_reply_markup message
        end
      end

      LOCATION_MAP = {
        callback_query: {
          id: [:callback_query, :message, :message_id],
          chat_id: [:callback_query, :message, :chat, :id],
          user_id: [:callback_query, :from, :id],
          body: [:callback_query, :data]
        },
        inline_query: {
          id: [:message,  :message_id],
          chat_id: [:message, :chat, :id],
          user_id: [:message, :from, :id],
          body: [:inline_query, :query]
        },
        message: {
          id: [:message,  :message_id],
          chat_id: [:message, :chat, :id],
          user_id: [:message, :from, :id],
          body: [:message, :text]
        }
      }.freeze

      def parse update_payload
        locations = LOCATION_MAP.find { |k, v| update_payload.key? k }&.second

        id = update_payload.dig(*locations[:id])

        chat_obj = AutumnMoon::Chat.new id: update_payload.dig(*locations[:chat_id])
        user_obj = AutumnMoon::User.new id: update_payload.dig(*locations[:user_id])

        body = update_payload.dig(*locations[:body])
        body ||= ""

        message_obj = AutumnMoon::Message.new(
          id: id,
          body: body,
          chat: chat_obj,
          user: user_obj,
          original: {
            telegram: update_payload
          }
        )

        message_obj
      end

      def receive with_bot:
        client.get_updates.each do |update|
          next if seen_updates.include? update[:update_id]

          Rails.logger.debug "Recieved update ID #{ update[:update_id] } from telegram with message ID #{ update[:message][:message_id] }"

          message_obj = parse update
          results = with_bot.dispatch message: message_obj
          results.each { |result| send result }

          seen_updates << update[:update_id]
        end
      end

      private

      def seen_updates
        @seen_updates ||= client.get_updates.map { |update| update[:update_id] }
      end
    end
  end
end

# module AutumnMoon
  # class TelegramAdaptor
    # class << self
      # def [] token:
        # method(:call).curry.call TelegramClient.new(token: token)
      # end

      # def command *args
        # route :command, *args
      # end

      # def message *args
        # route :message, *args
      # end

      # def inline_query *args
        # route :inline_query, *args
      # end

      # def location *args
        # route :location, nil, *args
      # end

      # def callback_query *args
        # route :callback_query, nil, *args
      # end

      # def default *args
        # route :all, "*", *args
      # end

      # def build_params_from payload:
        # params = {}

        # if payload[:callback_query]
          # payload = payload[:callback_query]

          # params = {
            # verb: :callback_query,
            # message_id: payload[:message][:message_id],
            # chat_id: payload[:message][:chat][:id],
            # user_id: payload[:from][:id],
            # timestamp: Time.at(payload[:message][:date]),
            # text: "",
            # entities: [],
            # metadata: {
              # data: payload[:data],
              # telegram: {
                # user: payload[:from]
              # }
            # }
          # }
        # elsif payload.dig(:message, :location)
          # payload = payload[:message]

          # params = {
            # verb: :location,
            # message_id: payload[:message_id],
            # chat_id: payload[:chat][:id],
            # user_id: payload[:from][:id],
            # timestamp: Time.at(payload[:date]),
            # text: "",
            # entities: [],
            # metadata: {
              # location: payload[:location],
              # telegram: {
                # user: payload[:from]
              # }
            # }

          # }
        # elsif payload[:message]
          # payload = payload[:message]
          # entities = payload.fetch(:entities, []).map do |entity|
            # entity[:type] = entity[:type].to_sym
            # entity[:text] = payload[:text][entity[:offset], entity[:length]]
            # entity
          # end.group_by { |entity| entity[:type] }

          # params = {
            # verb: :message,
            # message_id: payload[:message_id],
            # chat_id: payload[:chat][:id],
            # user_id: payload[:from][:id],
            # timestamp: Time.at(payload[:date]),
            # text: payload[:text],
            # entities: entities,
            # metadata: {
              # telegram: {
                # user: payload[:from]
              # }
            # }
          # }

          # if entities[:bot_command]
            # params[:metadata][:command] = entities[:bot_command].min { |c| c[:offset] }[:text]
            # params[:verb] = :command
          # end
        # elsif payload[:inline_query]
          # payload = payload[:inline_query]

          # params = {
            # verb: :inline_query,
            # message_id: payload[:id],
            # chat_id: payload[:id],
            # user_id: payload[:from][:id],
            # timestamp: Time.current,
            # text: payload[:query],
            # entities: [],
            # metadata: {
              # telegram: {}
            # }
          # }
        # end

        # params
      # end
    # end

    # def me
      # @me ||= client.get_me
    # end

    # def bot_name
      # me[:username]
    # end

    # def respond_with **options
      # message = options.merge(
        # chat_id: params[:chat_id]
      # )

      # Rails.logger.debug "Responding to chat #{ params[:chat_id] }, message #{ params[:message_id] }"

      # res = client.send_message message

      # session[:previous_message_id] = res[:message_id]

      # res
    # end

    # def reply_with **options
      # message = options.merge(
        # chat_id: params[:chat_id],
        # reply_to_message_id: params[:message_id]
      # )

      # Rails.logger.debug "Replying to message #{ params[:message_id] } in chat #{ params[:chat_id] }"

      # res = client.send_message message

      # session[:previous_message_id] = res[:message_id]

      # res
    # end

    # def inline_reply_with **options
      # message = options.merge(
        # inline_query_id: params[:chat_id]
      # )

      # Rails.logger.debug "Replying to inline query #{ params[:chat_id] }"

      # res = client.answer_inline_query message
      # # binding.pry

      # # session[:previous_message_id] = res[:message_id]

      # res
    # end

    # def edit_message_reply_markup **options
      # res = client.edit_message_reply_markup chat_id: params[:chat_id], message_id: params[:message_id], reply_markup: options
      # # binding.pry

      # # session[:previous_message_id] = res[:message_id]

      # res
    # end
  # end
# end
