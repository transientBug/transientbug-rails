module QueryGrammar
  module AST
    autoload :Node, "query_grammar/ast/node"
    autoload :Clause, "query_grammar/ast/clause"
    autoload :Negator, "query_grammar/ast/negator"
    autoload :Group, "query_grammar/ast/group"
  end
end
