module AutumnMoon
  module ContextRouter
    def self.registered klass
      # klass.set({})
      # klass.extend ClassMethods
      klass.prepend InstanceMethods
    end

    def self.route_added klass, pattern, method_name, conditions, options, route
      context = options[:context]
      return unless context

      unbound_method = klass.generate_unbound_method "unbound_condition" do
        session[:context] == context
      end

      route.conditions << unbound_method

      klass.before method_name do
        clear_context
      end
    end

    module InstanceMethods
      def clear_context
        session.delete :context
      end

      def set_context value
        session[:context] = value
      end
    end
  end
end
