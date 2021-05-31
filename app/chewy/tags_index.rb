# frozen_string_literal: true

class TagsIndex < Chewy::Index
  class << self
    def build_tag_suggest tag
      {
        input: tag.label.downcase,
        contexts: {
          type: [ :tag ]
        }
      }
    end
  end

  field :label, type: :keyword

  field :suggest,
        type: :completion,
        contexts: [ { name: :type, type: :category } ],
        value: ->(t) { build_tag_suggest t }
end
