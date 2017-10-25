module AutumnMoon
  module Cache
    def self.registered klass
      klass.set(
        cache_store: ActiveSupport::Cache::MemoryStore,
        cache_options: []
      )

      klass.extend ClassMethods
      klass.prepend InstanceMethods
    end

    def self.route_added klass, pattern, method_name, conditions, options, route
      klass.after method_name do
        cache.write cache_key, session
      end
    end

    module InstanceMethods
      def cache
        self.class.cache
      end

      def cache_key
        @cache_key ||= "#{ params[:chat][:id] }#{ params[:from][:id] }"
      end

      def session
        @session ||= cache.fetch cache_key do
          super
        end
      end
    end

    module ClassMethods
      def cache
        @cache ||= settings[:cache_store].new(*settings[:cache_options])
      end
    end
  end
end
