# frozen_string_literal: true

module QueryGrammar
  class Index
    class OperatorDsl
      attr_reader :operator

      def self.build(**opts, &)
        new(**opts).tap do |obj|
          obj.instance_eval(&)
        end.operator
      end

      def initialize **opts
        op_data = {
          name: nil,
          description: nil,
          arity: nil,
          type: nil,
          parse: nil,
        }.merge opts

        # rubocop:disable Style/OpenStructUse
        # This isn't built out of user supplied data and it's a lot more
        # convenient to use OpenStruct while prototyping
        @operator = OpenStruct.new op_data
        # rubocop:enable Style/OpenStructUse
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
