class ApplicationSearcher
  class QueryTransformer < Parslet::Transform
    rule(clause: subtree(:clause)) do
      operator = clause[:operator]&.to_s
      field = clause[:field]&.to_s

      next PhraseClause.new operator, field, clause[:phrase] if clause[:phrase]

      TermClause.new operator, field, clause[:term]
    end

    rule(query: sequence(:clauses)) { Query.new(clauses) }
  end
end
