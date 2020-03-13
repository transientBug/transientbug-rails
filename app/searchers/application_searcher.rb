# frozen_string_literal: true

class ApplicationSearcher
  class << self
    attr_reader :index, :compiler, :search

    def define_index &block
      @index = QueryGrammar::Index.build(&block)
    end

    def use_compiler val
      @compiler = val
    end

    def execute_query &block
      @search = block
    end
  end

  def search query
    ast = QueryGrammar.parse query, index: self.class.index
    compiled_query = self.class.compiler.new.compile ast
    QueryGrammar::Cloaker.new(bind: self).cloak(compiled_query, &self.class.search)
  end
end
