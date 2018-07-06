class ApplicationSearcher
  module Concerns
    module Chewy
      extend ActiveSupport::Concern

      class_methods do
        attr_reader :index_klass

        def index klass
          @index_klass = klass
        end

        def type_mappings
          index_klass.mappings_hash.values.first[:properties].each_with_object({}) do |(key, data), memo|
            memo[ key ] = data[:type].to_sym
          end
        end
      end

      def query input=nil, &block
        chewy_modifiers << block if block_given?

        super input, &block
      end

      def chewy_modifiers
        @chewy_modifiers ||= []
      end

      def chewy_results
        @chewy_results ||= begin
          es_results = queries.inject(self.class.index_klass) { |memo, query| memo.query query }
          chewy_modifiers.reverse.inject(es_results) { |memo, modifier| modifier.call memo }
        end
      end

      def results
        @results ||= begin
          return fetch [] if blank_query?

          fetch chewy_results
        end
      end
    end
  end
end
