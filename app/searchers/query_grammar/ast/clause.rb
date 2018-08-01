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
