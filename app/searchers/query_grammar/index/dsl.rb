module QueryGrammar
  class Index
    class DSL
      def self.build &block
        new.tap do |obj|
          obj.instance_eval(&block)
        end.index
      end

      def index
        @index ||= QueryGrammar::Index.new
      end

      def type key, &block
        index.types[ key ] = block
      end

      def default *args
        args.each do |field|
          index.fields[ field.to_s ][:default] = true
        end
      end

      def operator prefix, **opts, &block
        index.operators[ prefix.to_s ] = QueryGrammar::Index::OperatorDSL.build(**opts, &block)
      end

      # rubocop:disable Style/MethodMissing
      def respond_to_missing? func, *args
        return true if index.types[ func ]

        super
      end

      def method_missing func, *args, **opts, &block
        if index.types[ func ]
          field = {
            aliases: (opts.delete(:aliases) || []).map(&:to_s),
            existable: false,
            sortable: false,
            default: false,
            type: func,
            parse: index.types[ func ]
          }.merge opts

          index.fields[ args.first.to_s ] = OpenStruct.new field

          return field
        end

        super
      end
      # rubocop:enable Style/MethodMissing
    end
  end
end
