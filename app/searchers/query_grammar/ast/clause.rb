module QueryGrammar
  module AST
    class Clause < Node
      attr_reader :unary, :prefix, :value

      def initialize  unary: nil, prefix: nil, value: nil
        @unary = unary
        @prefix = prefix
        @value = value
      end

      def values
        Array(value)
      end

      def accept visitor
        if value.is_a? Array
          visitor.visit_value_list value, self
        elsif value.is_a? Date
          visitor.visit_value_date value, self
        elsif value.index " "
          visitor.visit_value_phrase value, self
        end

        visitor.visit_value value, self

        unless prefix.blank?
          prefix_visitor = :"visit_prefix_#{ prefix }"
          if visitor.respond_to? prefix_visitor
            visitor.send prefix_visitor, self
          end

          visitor.visit_prefix prefix, self
        end

        unless unary.blank?
          unary_visitor = :"visit_unary_#{ unary }"
          if visitor.respond_to? unary_visitor
            visitor.send unary_visitor, self
          end

          visitor.visit_unary unary, self
        end

        visitor.visit_clause self
      end

      def to_h
        {
          clause: {
            unary: unary,
            prefix: prefix,
            values: values.map do |val|
              type = :date if val.is_a? Date
              type ||= :phrase if val.index(" ")
              type ||= :term

              {
                type: type,
                value: val.as_json
              }
            end
          }.compact
        }
      end

      def to_s
        val = Array(value).map do |entry|
          next entry.to_s if entry.is_a? Date
          next "\"#{ entry }\"" if entry.index(" ")
          entry
        end.join " "

        val = "(#{ val })" if value.is_a? Array

        "#{ unary }#{ prefix }#{ prefix ? ":" : "" }#{ val }"
      end

      def == other
        return false unless other.is_a? Clause
        unary == other.unary && prefix == other.prefix && value == other.value
      end
    end
  end
end
