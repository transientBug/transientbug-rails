module AutumnMoon
  class ContextDecomposer < AutumnMoon::Decomposer
    module ControllerMethods
      def set_context value
        session[:context] = value
      end

      def clear_context
        session.delete :context
      end
    end

    def modify_route route
      return route unless route.options[:context]

      route.on_conditions << lambda do
        session[:context] == route.options[:context]
      end
    end
  end
end
