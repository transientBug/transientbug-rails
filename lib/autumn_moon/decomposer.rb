module AutumnMoon
  class Decomposer
    def modify_route route
      route
    end

    def call message:
      message.decompositions[ self.class.name.to_sym ] = handle_message message
      message
    end

    def handle_message message; end
  end
end
