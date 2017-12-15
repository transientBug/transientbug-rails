# module AutumnMoon
  # # Container for representing a single route. Takes the methods name and
  # # pattern that matches, along with an array of conditions that should allow
  # # this route to match.
  # class Route
    # attr_reader :pattern, :method_name, :conditions, :options

    # def initialize verb, pattern, method_name, conditions: [], **options
      # @verb = verb
      # @raw_pattern = pattern
      # @method_name = method_name
      # @conditions = Array(conditions)
      # @options = options
    # end

    # def pattern
      # @pattern ||= Mustermann.new @raw_pattern, **options.fetch(:mustermann_options, {})
    # end

    # def match klass, params
      # unless @raw_pattern.nil?
        # return false unless pattern.match(params[:text])
      # end

      # return true if @verb == :all
      # return false unless params[:verb] == @verb

      # conditions.all? do |condition|
        # condition.bind(klass).call
      # end
    # end
  # end
# end
