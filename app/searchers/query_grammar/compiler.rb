# frozen_string_literal: true

module QueryGrammar
  class Compiler
    autoload :ES, "query_grammar/compiler/es"

    class << self
      def visitors
        @visitors ||= ancestor_hash :visitors
      end

      def visit klass, &block
        visitors[ klass ] = block
      end

      protected

      # Allow classes to inherit their ancestors fields, joiners, types and
      # operations. This allows for progressively building searchers up, such as
      # having an ElasticsearchSearcher that defines the operations to build ES
      # queries, a BookmarksSearcher that inherits those operations while
      # defining public user facing searchable fields, and an
      # Admin::BookmarksSearcher which defines additional fields that are
      # available within the admin panel
      def ancestor_hash func
        (ancestors - [self])
          .select { |i| i.ancestors.include? QueryGrammar::Compiler }
          .inject({}) { |memo, i| memo.merge i.send func }
      end
    end

    def visitors
      self.class.visitors
    end

    def finalize
      fail NotImplementedError
    end

    def respond_to_missing? func, *args
      name = func.to_s.gsub(%r{^visit_}, "").to_sym

      return true if visitors.key? name

      super
    end

    # fuck you too rubocop, this does fallback to super
    def method_missing func, *args
      name = func.to_s.gsub(%r{^visit_}, "").to_sym

      return super unless visitors.key? name

      QueryGrammar::Cloaker.new(bind: self).cloak(*args, &visitors[name])
    rescue => e
      # Hack to remove this method_missing from the backtrace
      e.set_backtrace e.backtrace[1..-1]
      fail e
    end
  end
end
