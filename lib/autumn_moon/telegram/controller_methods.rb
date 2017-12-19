module AutumnMoon
  module Telegram
    module ControllerMethods
      def respond_with text:, **extra
        build_reply text: text, extra: { intent: :respond, telegram: extra }
      end

      def reply_with text:, **extra
        build_reply text: text, extra: { intent: :reply, telegram: extra }
      end

      def inline_reply_with results: [], **extra
        build_reply text: "", extra: { intent: :inline_reply, inline_reply: reults, telegram: extra }
      end

      def edit_message_reply_markup inline_keyboard:, **extra
        build_reply text: "", extra: { intent: :edit_markup, edit_markup: inline_keyboard, telegram: extra }
      end

      # def edit_message_text *args
      # end

      # def edit_message_caption *args
      # end

      # def delete_message *args
      # end
    end
  end
end
