module AutumnMoon
  class Bot
    class Route
      attr_reader :pattern, :method_name, :unbound_method, :conditions, :options

      def initialize pattern, method_name, conditions: [], **options
        @raw_pattern = pattern
        @method_name = method_name
        @conditions = Array(conditions)
        @options = options
      end

      def pattern
        @pattern ||= Mustermann.new @raw_pattern, **options.fetch(:mustermann_options, {})
      end
    end

    class << self
      # Settings handling
      def settings
        @settings ||= {}
        return superclass.settings.merge @settings if superclass.respond_to?(:settings)
        @settings
      end

      def set **options
        @settings ||= settings.merge options
      end

      # Extension handling
      def extensions
        @extensions ||=  []
        return (@extensions + superclass.extensions).uniq if superclass.respond_to?(:extensions)
        @extensions
      end

      def register *extension_modules, &block
        extension_modules << Module.new(&block) if block_given?

        extensions
        @extensions += extension_modules

        extensions.each do |extension|
          extension.registered self if extension.respond_to? :registered
        end
      end

      def invoke_hook name, *args
        extensions.each { |e| e.send(name, self, *args) if e.respond_to? name }
      end

      # Filter handling
      def filters
        @filters ||= Hash.new { |hash, key| hash[key] = { before: [], after: [] } }
      end

      def add_filter type, method_name, **options, &block
        block = -> { self.method(options.delete(:use)).call } unless block_given?

        unbound_method = generate_unbound_method "unbound_#{ type }", &block

        filters[method_name][type] << [ options, unbound_method ]
        invoke_hook :filter_added, method_name, type, options, unbound_method
      end

      def before method_name, **options, &block
        add_filter :before, method_name, **options, &block
      end

      def after method_name, **options, &block
        add_filter :after, method_name, **options, &block
      end

      # Route handling
      def routes
        @routes ||= []
      end

      def route pattern, to:, on: [], **options
        method_name = to

        conditions = Array(on).map do |condition|
          generate_unbound_method "unbound_condition", &condition
        end

        route = Route.new(pattern, method_name, conditions: conditions, **options)

        routes << route
        invoke_hook :route_added, pattern, method_name, conditions, options, route
      end

      # Message handling
      def build_params_from payload:
        fail NotImplementedError
      end

      def call payload
        params = build_params_from payload: payload

        new.call params

        nil
      end

      def generate_unbound_method method_name, &block
        define_method method_name, &block
        method = instance_method method_name
        remove_method method_name
        method
      end
    end

    attr_reader :params

    def settings
      self.class.settings
    end

    def session
      @session ||= {}
    end

    def bot_name
      fail NotImplementedError
    end

    def pass
      throw :pass
    end

    def halt
      throw :halt
    end

    def call params
      @params = params

      catch :halt do
        self.class.routes.each do |route|
          next unless route.pattern.match(params[:text])
          next unless route.conditions.all? do |condition|
            condition.bind(self).call
          end

          catch :pass do
            self.class.filters.dig(route.method_name, :before).each { |o, c| c.bind(self).call }
            send route.method_name
            self.class.filters.dig(route.method_name, :after).each { |o, c| c.bind(self).call }

            halt
          end
        end
      end
    end
  end
end
