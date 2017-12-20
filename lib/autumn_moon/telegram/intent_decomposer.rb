module AutumnMoon
  module Telegram
    class IntentDecomposer < AutumnMoon::Decomposer
      def modify_route route
        return route unless route.options[:intent]

        route.on_conditions << lambda do
          message.decompositions[:"AutumnMoon::Telegram::IntentDecomposer"] == route.options[:intent]
        end
      end

      def handle_message message
        return :callback_query if message.original[:telegram][:callback_query]
        return :location if message.original[:telegram][:message][:location]
        return :inline_query if message.original[:telegram][:inline_query]

        return :command if message.body.match?(%r{^/.*})
        return :message if message.original[:telegram][:message]
      end
    end
  end
end
