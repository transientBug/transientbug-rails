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
          .select { |i| i.ancestors.include? Compiler }
          .inject({}) { |memo, i| memo.merge i.send func }
      end
    end

    def visitors
      self.class.visitors
    end

    def finalize
      fail NotImplementedError
    end

    def method_missing func, *args
      str_name = func.to_s
      return super(func, *args) unless str_name.start_with? "visit_"

      name = str_name.gsub(/^visit_/, "").to_sym

      if visitors.key? name
        return QueryGrammar::Cloaker.new(bind: self).cloak(*args, &visitors[name])
      end
    end
  end
end
