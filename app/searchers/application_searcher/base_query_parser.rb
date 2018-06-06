class ApplicationSearcher
  class BaseQueryParser < Parslet::Parser
    rule(:eof) { any.absent? }

    rule(:operator) { (str("+") | str("-")).as(:operator) }

    rule(:space)  { match("\s").repeat(1) }
    rule(:quote) { str("\"") }
    rule(:colon) { str(":") }
    rule(:word) { match("[^\s\"]").repeat(1) }

    rule(:term) { word.as(:term) }

    rule(:phrase) do
      quote >> (word >> space.maybe).repeat.as(:phrase) >> quote
    end

    def self.fields *args
      args.each do |arg|
        rule("#{ arg }_field") { str(arg).as(:field) >> colon }
      end

      rule(:field) do
        first = send(:"#{ args.first }_field")
        args[1..-1].reduce(first) { |memo, arg| memo.| send(:"#{ arg }_field") }
      end
    end

    rule(:field_only_clause) { operator.maybe >> field >> (space | eof).present? }
    rule(:field_term_clause) { operator.maybe >> field.maybe >> (phrase | term) }

    rule(:clause) { (field_only_clause | field_term_clause).as(:clause) }

    rule(:query) { (clause >> space.maybe).repeat.as(:query) }

    root(:query)
  end
end
