# frozen_string_literal: true

module QueryGrammar
  class Index
    class OperatorDsl
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

      def respond_to_missing?(*)
        true
      end

      def method_missing func, *args, **_opts, &block
        @operator[ func ] = args.first || block
      end
    end
  end
end
