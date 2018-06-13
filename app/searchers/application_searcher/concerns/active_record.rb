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
      end

      def fetch res
        if res.none?
          records = self.class.model_klass.none
        else
          records = self.class.model_klass.where self.class.model_klass.primary_key => res.pluck(:_id)
        end

        return records unless activerecord_modifiers.any?
        activerecord_modifiers.reverse.inject(records) { |memo, modifier| modifier.call memo }
      end
    end
  end
end
