module AutumnMoon
  class Router
    attr_reader :routes, :decomposers

    def initialize
      @routes = []
      @decomposers = []
    end

    def add_decomposer decomposer
      @decomposers << decomposer.new
    end

    def build_route *args
      routes << decomposers.each_with_object(Route.new(*args)) do |decomposer, memo|
        decomposer.modify_route memo
      end
    end

    def decompose message
      decomposers.each_with_object(message) do |decomposer, memo|
        decomposer.call message: memo
      end
    end

    def dispatch bot_instance
      found_route = routes.find { |route| route.match? bot_instance }

      fail NoRouteMatchesError unless found_route

      found_route.call bot_instance
    end
  end
end
