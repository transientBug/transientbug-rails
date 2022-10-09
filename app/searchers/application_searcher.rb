# frozen_string_literal: true

class ApplicationSearcher
  class << self
    attr_reader :index, :compiler, :search

    def define_index(&)
      @index = QueryGrammar::Index.build(&)
    end

    def use_compiler val
      @compiler = val
    end

    def execute_query &block
      @search = block
    end
  end

  def search query
    query
      .then { QueryGrammar.parse _1, index: self.class.index }
      .then { self.class.compiler.compile _1 }
      .then { QueryGrammar::Cloaker.new(bind: self).cloak _1, &self.class.search }
  end
end
