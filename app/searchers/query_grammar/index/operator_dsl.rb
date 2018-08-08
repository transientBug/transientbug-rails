module QueryGrammar
  class Index
    class OperatorDSL
      attr_reader :operator

      def self.build **opts, &block
        new(**opts).tap do |obj|
          obj.instance_eval(&block)
        end.operator
      end

      def initialize **opts
        @operator = {
          name: nil,
          description: nil,
          arity: nil,
          type: nil,
          compile: nil
        }.merge(opts)
      end

      # rubocop:disable Style/MethodMissing
      def respond_to_missing? func, **args
        return true
      end

      def method_missing func, *args, **opts, &block
        @operator[ func ] = args.first || block
      end
      # rubocop:enable Style/MethodMissing
    end
  end
end
