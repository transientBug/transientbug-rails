module AutumnMoon
  class Bot
    class Route
      attr_reader :pattern, :method_name, :conditions

      def initialize pattern, method_name:, conditions: []
        @raw_pattern = pattern
        @conditions = Array(conditions)
        @method_name = method_name
      end

      def pattern
        @pattern ||= Mustermann.new @raw_pattern
      end

      def match params
        return false unless should_match? params
        return false unless pattern.match match_text_for(params)

        conditions.all? { |condition| condition.call params }
      end

      protected

      def should_match? params
        fail NotImplementedError
      end

      def match_text_for params
        fail NotImplementedError
      end
    end

    # class CommandRoute < Route
    #   def pattern
    #     @pattern ||= Mustermann.new @raw_pattern
    #   end

    #   def should_match? params
    #     params[:entities][:bot_command].present?
    #   end

    #   def match_text_for params
    #     params[:entities][:bot_command]
    #   end
    # end

    class HandlerRoute < Route
      def should_match? params
        true
      end

      def match_text_for params
        params[:text]
      end
    end

    class << self
      def routes
        @routes ||= []
      end

      def default_route
        @default_route ||= nil
      end

      def default to:
        @default_route = to
      end

      # def command pattern, to:, on: []
      #   routes << CommandRoute.new(pattern, method_name: to, conditions: on)
      # end

      def handle pattern, to:, on: []
        routes << HandlerRoute.new(pattern, method_name: to, conditions: on)
      end

      def route payload
        entities = payload[:entities].map do |entity|
          entity[:type] = entity[:type].to_sym
          entity[:text] = payload[:text][entity[:offset], entity[:length]]
          entity
        end.group_by { |entity| entity[:type] }

        if entities[:bot_command]
          entities[:bot_command] = entities[:bot_command].first[:text]
        end

        timestamp = Time.at payload[:date]

        params = {
          entities: entities,
          text: payload[:text],
          timestamp: timestamp
        }.merge(payload.slice(:message_id, :from, :chat))

        # TODO: Handle conditionals that are methods? (maybe class methods?)
        route_handler = routes.find { |route| route.match(params) }.method_name
        route_handler ||= default_route

        new(params).route route_handler
      end
    end

    attr_reader :params

    def initialize params
      @params = params
    end

    def route method
      # TODO: Before, Around, After callbacks
      public_send method
    end
  end
end
