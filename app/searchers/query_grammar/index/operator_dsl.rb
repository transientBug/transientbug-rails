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
        op_data = {
          name: nil,
          description: nil,
          arity: nil,
          type: nil,
          parse: nil
        }.merge opts

        @operator = OpenStruct.new op_data
      end

      # rubocop:disable Style/MethodMissing
      def respond_to_missing?(*)
        true
      end

      # rubocop:disable Style/MethodMissingSuper
      def method_missing func, *args, **_opts, &block
        @operator[ func ] = args.first || block
      end
      # rubocop:enable Style/MethodMissingSuper
      # rubocop:enable Style/MethodMissing
    end
  end
end
