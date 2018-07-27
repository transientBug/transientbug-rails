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
      expression
    end

    rule :expression do
      or_expression | and_expression | group | clause
    end

    rule :group do
      negator.maybe >> str("(") >> space? >> expression >> space? >> str(")")
    end

    rule :and_expression do
      ((group | or_expression | clause) >>
       ((space >> str("AND")).maybe >> space >>
        (group | or_expression | clause)).repeat(1)).as(:and_expression)
    end

    rule :or_expression do
      ((clause | group | and_expression) >>
       (space >> str("OR") >> space >>
        (clause | group | and_expression)).repeat(1)).as(:or_expression)
    end

    ##################################

    rule :clause do
      (negator.maybe >>
       ((prefix >> ( term | term_list ).maybe) |
         term
       )).as(:clause)
    end

    rule :prefix do
      unary.maybe >> word.as(:prefix) >> str(":")
    end

    rule :negator do
      (str("NOT") >> space.repeat(1)).as(:negator).maybe
    end

    rule :unary do
      match["^[:alnum:]"].as(:unary)
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

    # rule :prefix do
    #   args = methods.select { |m| m.to_s.end_with? "_prefix" }
    #   first = send(args.first)
    #   args[1..-1].reduce(first) { |memo, arg| memo.| send(arg) }.as(:prefix)
    # end

    # def self.prefixes *args
    #   args.each do |arg|
    #     rule("#{ arg }_prefix") { str(arg) }
    #   end
    # end

    # prefixes :title, :description, :tag, :tags, :after, :before, :host, :url, :has
  end
end
