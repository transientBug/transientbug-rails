module AutumnMoon
  module Telegram
    class Adaptor < AutumnMoon::Adaptor
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
          message = {
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
