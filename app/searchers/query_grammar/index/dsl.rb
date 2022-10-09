# frozen_string_literal: true

module QueryGrammar
  class Index
    class Dsl
      def self.build(&)
        new.tap do |obj|
          obj.instance_eval(&)
        end.index
      end

      def index
        @index ||= QueryGrammar::Index.new
      end

      def type key, &block
        index.types[ key ] = block
      end

      def field key, type:, **opts
        fail "Type #{ type } not defined yet!" unless index.types[ type ]

        field = {
          aliases: (opts.delete(:aliases) || []).map(&:to_s),
          existable: false,
          sortable: false,
          default: false,
          type:,
          parse: index.types[ type ],
          **opts,
        }

        # rubocop:disable Style/OpenStructUse
        # This isn't built out of user supplied data and it's a lot more
        # convenient to use OpenStruct while prototyping
        index.fields[ key.to_s ] = OpenStruct.new field
        # rubocop:enable Style/OpenStructUse

        field
      end

      def operator(prefix, **opts, &)
        index.operators[ prefix.to_s ] = QueryGrammar::Index::OperatorDsl.build(**opts, &)
      end

      def fallback(&block)
        index.fallback = block
      end

      def default *args
        args.each do |field|
          index.fields[ field.to_s ][:default] = true
        end
      end

      # def respond_to_missing? func, *args
        # return true if index.types[ func ]

        # super
      # end

      # def method_missing(func, *args, **opts, &)
        # if index.types[ func ]
          # field = {
            # aliases: (opts.delete(:aliases) || []).map(&:to_s),
            # existable: false,
            # sortable: false,
            # default: false,
            # type: func,
            # parse: index.types[ func ],
          # }.merge opts

          # # rubocop:disable Style/OpenStructUse
          # # This isn't built out of user supplied data and it's a lot more
          # # convenient to use OpenStruct while prototyping
          # index.fields[ args.first.to_s ] = OpenStruct.new field
          # # rubocop:enable Style/OpenStructUse

          # return field
        # end

        # super
      # end
    end
  end
end
