class ApplicationSearcher
  module Concerns
    module ActiveRecord
      extend ActiveSupport::Concern

      included do
      end

      class_methods do
        attr_reader :model_klass

        def model klass
          @model_klass = klass
        end
      end

      def activerecord_modifiers
        @activerecord_modifiers ||= []
      end

      def activerecord_modifier &block
        activerecord_modifiers << block if block_given?
        self
      end

      # rubocop:disable Metrics/AbcSize
      def fetch res
        records = self.class.model_klass.none if res.none?
        records ||= self.class.model_klass.where self.class.model_klass.primary_key => res.pluck(:_id)

        activerecord_modifiers.reverse.inject(records) { |memo, modifier| modifier.call memo }
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
