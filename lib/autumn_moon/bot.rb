module AutumnMoon
  # Base Bot "Controller" class with minimal routing, setting and extension
  # patterns borrowed/inspired from Sinatra. Inherit, override
  # +build_params_from+ and use the route DSL to create a new controller which
  # can be routed to with <klass>.call(payload).
  class Bot
    # Container for representing a single route. Takes the methods name and
    # pattern that matches, along with an array of conditions that should allow
    # this route to match.
    class Route
      attr_reader :pattern, :method_name, :conditions, :options

      def initialize verb, pattern, method_name, conditions: [], **options
        @verb = verb
        @raw_pattern = pattern
        @method_name = method_name
        @conditions = Array(conditions)
        @options = options
      end

      def pattern
        @pattern ||= Mustermann.new @raw_pattern, **options.fetch(:mustermann_options, {})
      end

      def match klass, params
        unless @raw_pattern.nil?
          return false unless pattern.match(params[:text])
        end

        return true if @verb == :all
        return false unless params[:verb] == @verb

        conditions.all? do |condition|
          condition.bind(klass).call
        end
      end
    end

    class << self
      # Settings and extensions we want to share across inherited classes which
      # is what the superclass merging is for. Routes and action callbacks
      # however are not shared, to avoid issues around methods or unbound
      # callbacks and allowing a base Bot class to exist within a larger set of
      # bot "controllers"

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

      # Before/After callback handling
      def action_callbacks
        @action_callbacks ||= { before: [], after: [] }
      end

      # Generates an unbound method for the given block or +use+ parameter
      # which will be bound to the specific instance of the Bot that is
      # handling the current request.
      def add_callback type, method_name, **options, &block
        # If a +use+ option was passed along instead of a block, assume that it
        # is the name of an instance method that should be called instead of a
        # block.
        block = -> { self.send options.delete(:use) } unless block_given?

        unbound_method = generate_unbound_method "unbound_#{ type }", &block

        action_callbacks[type] << [ method_name, options, unbound_method ]
        invoke_hook :filter_added, method_name, type, options, unbound_method
      end

      def before method_name, **options, &block
        add_callback :before, method_name, **options, &block
      end

      def after method_name, **options, &block
        add_callback :after, method_name, **options, &block
      end

      # Route handling
      def routes
        @routes ||= []
      end

      def route verb, pattern, to:, on: [], **options
        method_name = to

        conditions = Array(on).map do |condition|
          generate_unbound_method "unbound_condition", &condition
        end

        route = Route.new(verb, pattern, method_name, conditions: conditions, **options)

        routes << route
        invoke_hook :route_added, pattern, method_name, conditions, options, route
      end

      # Message handling

      # Builds out the params hash from a chat network payload object. This
      # should be overriden when this class is inherited. Should return a hash
      # with the following key/values:
      #   Hash{
      #     verb: Symbol
      #     message_id: String/Int
      #     chat_id: String/Int
      #     user_id: String/Int
      #     timestamp: Time
      #     text: String
      #     entities: Array(Hash{ type: Symbol, text: String })
      #     metadata: Hash
      #   }
      def build_params_from payload:
        fail NotImplementedError
      end

      def call client, payload
        params = build_params_from payload: payload

        new.call client, params

        nil
      end

      def generate_unbound_method method_name, &block
        define_method method_name, &block
        method = instance_method method_name
        remove_method method_name
        method
      end
    end

    attr_reader :client, :params

    def settings
      self.class.settings
    end

    def session
      @session ||= {}
    end

    def pass
      throw :pass
    end

    def halt
      throw :halt
    end

    def call client, params
      @client = client
      @params = params

      catch :halt do
        self.class.routes.each do |route|
          next unless route.match(self, params)

          catch :pass do
            self.class.action_callbacks[:before]
              .select { |n, o, c| n == route.method_name }
              .each { |n, o, c| c.bind(self).call }

            send route.method_name

            self.class.action_callbacks[:after]
              .select { |n, o, c| n == route.method_name }
              .each { |n, o, c| c.bind(self).call }

            halt
          end
        end
      end
    end
  end
end
