class ImagesIndex < Chewy::Index
   settings analysis: {
    analyzer: {
      title: {
        tokenizer: :standard,
        filter: [:lowercase, :english_stop, :trim, :edgeNGram]
      },
      tag: {
        tokenizer: :standard,
        filter: [:lowercase, :edgeNGram]
      }
    },
    filter: {
      english_stop: {
        type: :stop,
        stopwords: :_english_
      }
    }
  }

  TagStruct = Struct.new(:id, :tag) do
    def self.from tag
      new tag, tag
    end
  end

  define_type Image.where(disabled: false) do
    field :title, type: "text", term_vector: "yes", analyzer: :title
    field :tags, type: "text", analyzer: :tag
    field :raw_tags, type: "text", value: ->(image) { image.tags }

    field :suggest, type: "completion", contexts: [ { name: :type, type: :category } ], value: ->(image) {
      tags = image.tags.map(&:downcase)

      {
        input: [image.title.downcase].concat(tags),
        contexts: {
          type: [:image]
        }
      }
    }

    field :source, type: "keyword"

    field :created_at, type: "date", include_in_all: false
  end

  def self.numbered_tags
    ActiveRecord::Base.connection.execute("SELECT DISTINCT UNNEST(tags) AS tag FROM images WHERE disabled = FALSE").to_a
      .map { |row| TagStruct.from row["tag"] }
  end

  define_type -> { numbered_tags }, name: :tag do
    field :tag, type: "text", value: ->(tag_struct) { tag_struct.tag }, analyzer: :tag
    field :raw_tag, type: "keyword", value: ->(tag_struct) { tag_struct.tag }
    field :suggest, type: "completion", contexts: [ { name: :type, type: :category } ], value: ->(tag_struct) {
      {
        input: tag_struct.tag.downcase,
        contexts: {
          type: [:tag]
        }
      }
    }
  end
end
