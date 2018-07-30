module QueryGrammar
  # Query Grammar Definition
  # Enables parsing something like this:
  #   "middle earth" OR earth AND (tag:computers OR +tag:rendering) AND after:2014-01-01 AND
  #   before:2018-06-14 AND NOT host:wired.com
  # Into a usable data structure that can then be transformed into a usable query AST
  #
  # EBNF Grammar:
  #      Query ::= Expression
  #
  #      Expression ::= AndExpression | OrExpression | Group | Clause
  #
  #      Group ::= Negator? '(' Space* Expression Space* ')'
  #
  #      OrExpression ::= (Clause | Group | AndExpression) (Space+ 'OR' Space+ (Clause | Group | AndExpression))+
  #
  #      AndExpression ::= (Group | OrExpression | Clause) ((Space+ 'AND')? Space+ (Group | OrExpression | Clause))+
  #
  #      Clause ::= Negator? ((Prefix ( Term | TermList )?) | Term)
  #
  #      Prefix ::= Unary? Word ':'
  #
  #      Negator ::= 'NOT' Space+
  #      Unary ::= [^a-fA-F0-9]
  #
  #      TermList ::= '(' Space* (Term Space*)+ ')'
  #
  #      Term ::= Word | Phrase
  #      Phrase ::= '"' [^"]* '"'
  #
  #      Word ::= [^:")(#x9#xA#xD#x20]+
  #      Space ::= #x9 | #xA | #xD | #x20
  class Parser < Parslet::Parser
    root :query

    rule :query do
      any.absent? | expression
    end

    rule :expression do
      (or_group | and_group | group | clause).as(:expression)
    end

    rule :group do
      negator.maybe >> str("(") >> space? >> expression >> space? >> str(")")
    end

    rule :and_group do
      ((group | or_group | clause) >>
       ((space >> str("AND")).maybe >> space >>
        (group | or_group | clause)).repeat(1)).as(:and_group)
    end

    rule :or_group do
      ((group | clause | and_group) >>
       (space >> str("OR") >> space >>
        (group | clause | and_group)).repeat(1)).as(:or_group)
    end

    # This causes stack too deep errors still since expression includes infix
    # rule :infix_group do
    #   infix_expression(
    #     expression,
    #     [(space >> str("OR") >> space), 2, :left],
    #     [((space >> str("AND")).maybe >> space), 1, :left]
    #   ) do |l, o, r|
    #     { group: { conjoiner: o, values: [ l, r ].flatten } }
    #   end
    # end

    # #################################################################################################################
    # Base functionality
    # #################################################################################################################

    rule :clause do
      negator.maybe >> (
         ((unary.as(:unary).maybe >> prefix >> ( term | term_list ).maybe.as(:value)) |
        term.as(:value)
       )).as(:clause)
    end

    rule :prefix do
      (word.as(:term)).as(:prefix) >> str(":")
    end

    rule :negator do
      (str("NOT") >> space.repeat(1)).as(:negator).maybe
    end

    rule :unary do
      match["^[:alnum:]"].as(:term)
    end

    rule :term_list do
      str("(") >> space? >> (term >> space?).repeat(1).as(:term_list) >> str(")")
    end

    rule :term do
      word.as(:term) | phrase
    end

    rule :phrase do
      str('"') >> match['^"'].repeat.as(:phrase) >> str('"')
    end

    rule :word do
      match["^:\s\")("].repeat(1)
    end

    rule :space? do
      space.maybe
    end

    rule :space do
      match["\s"].repeat(1)
    end
  end
end
