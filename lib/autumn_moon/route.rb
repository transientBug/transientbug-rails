module AutumnMoon
  class Route
    attr_reader :raw_pattern, :to_controller_action, :on_conditions, :options

    def initialize pattern=nil, to:, on: [], **opts
      @raw_pattern = pattern
      @pattern = Mustermann.new pattern, **opts.fetch(:mustermann_options, {}) if pattern

      @to_controller_action = to.split("#")
      @on_conditions = Array(on)

      @options = opts
    end

    def controller
      @to_controller_action[0].camelize.constantize
    end

    def action
      @to_controller_action[1].to_sym
    end

    def match? bot
      if @pattern
        return false unless @pattern.match(bot.message.body)
      end

      on_conditions.all? do |condition|
        bot.instance_exec(&condition)
      end
    end

    def call bot
      controller.new(bot: bot).process action
    end
  end
end
