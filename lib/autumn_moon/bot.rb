module AutumnMoon
  class Bot
    class Route
      attr_reader :pattern, :method_name, :unbound_method, :conditions, :options

      def initialize pattern, method_name, unbound_method, conditions: [], **options
        @raw_pattern = pattern
        @method_name = method_name
        @unbound_method = unbound_method
        @conditions = Array(conditions)
        @options = options
      end

      def pattern
        @pattern ||= Mustermann.new @raw_pattern, **options
      end
    end

    class << self
      def routes
        @routes ||= []
      end

      def settings
        @settings ||= {
          cache_store: ActiveSupport::Cache::MemoryStore,
          cache_options: []
        }
      end

      def cache
        @cache ||= settings[:cache_store].new(*settings[:cache_options])
      end

      def filters
        @filters ||= Hash.new { |hash, key| hash[key] = { before: [], after: [] } }
      end

      def generate_method method_name, &block
        define_method method_name, &block
        method = instance_method method_name
        remove_method method_name
        method
      end

      def add_filter type, pattern, **options, &block
        block = -> { self.method(options.delete(:use)).call } unless block_given?

        unbound_method = generate_method "unbound_#{ type }", &block

        filters[pattern][type] << [ options, unbound_method ]
      end

      def before pattern, **options, &block
        add_filter :before, pattern, **options, &block
      end

      def after pattern, **options, &block
        add_filter :after, pattern, **options, &block
      end

      def route pattern, to:, on: [], **options
        block = -> { method(to).call }

        unbound_method = generate_method "unbound_route", &block

        conditions = Array(on).map do |condition|
          generate_method "unbound_condition", &condition
        end

        routes << Route.new(pattern, to, unbound_method, conditions: conditions, **options)
      end

      def build_params_from payload:
        fail NotImplementedError
      end

      def call payload
        params = build_params_from payload: payload

        new.call params
      end
    end

    attr_reader :params

    def settings
      self.class.settings
    end

    def cache
      self.class.cache
    end

    def cache_key
      @cache_key ||= "#{ params[:chat][:id] }#{ params[:from][:id] }"
    end

    def session
      @session ||= cache.fetch cache_key do
        {}
      end
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
            route.unbound_method.bind(self).call
            self.class.filters.dig(route.method_name, :after).each { |o, c| c.bind(self).call }

            halt
          end
        end
      end

      cache.write cache_key, session
    end
  end
end
