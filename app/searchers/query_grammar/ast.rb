# frozen_string_literal: true

module QueryGrammar
  module Ast
    autoload :Node, "query_grammar/ast/node"

    autoload :Negator, "query_grammar/ast/negator"
    autoload :Group, "query_grammar/ast/group"

    autoload :FieldValueClause, "query_grammar/ast/field_value_clause"

    autoload :GtRangeClause, "query_grammar/ast/gt_range_clause"
    autoload :LtRangeClause, "query_grammar/ast/lt_range_clause"
    autoload :RangeClause, "query_grammar/ast/range_clause"
    autoload :MatchClause, "query_grammar/ast/match_clause"
    autoload :EqualClause, "query_grammar/ast/equal_clause"
    autoload :SortClause, "query_grammar/ast/sort_clause"
  end
end
