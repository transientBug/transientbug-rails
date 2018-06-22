class ApplicationSearcher
  module Concerns
    module Pagination
      extend ActiveSupport::Concern

      included do
      end

      class_methods do
      end

      def total_pages
        chewy_results.total_pages
      end

      def current_page
        chewy_results.current_page
      end

      def limit_value
        chewy_results.limit_value
      end

      def page val
        query do |chewy|
          chewy.page val
        end

        self
      end

      def per val
        query do |chewy|
          chewy.per val
        end

        self
      end
    end
  end
end
