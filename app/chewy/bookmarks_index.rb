class BookmarksIndex < Chewy::Index
   settings analysis: {
    analyzer: {
      title: {
        tokenizer: :standard,
        filter: [:lowercase, :trim, :edgeNGram3x6]
      },
      description: {
        tokenizer: :standard,
        filter: [:lowercase, :trim, :english_stop, :edgeNGram3x6]
      },
      tag: {
        tokenizer: :standard,
        filter: [:lowercase, :trim, :edgeNGram3x6]
      }
    },
    filter: {
      english_stop: {
        type: :stop,
        stopwords: :_english_
      },
      edgeNGram3x6: {
        type: :edgeNGram,
        min_gram: 3,
        max_gram: 6
      }
    }
  }

  define_type Bookmark do
    field :uri, type: "keyword", value: ->(bookmark) { bookmark.uri_string }

    field :title, type: "text", term_vector: "yes", analyzer: :title
    field :description, type: "text", analyzer: :description

    field :tags, type: "text", analyzer: :tag, value: ->(bookmark) { bookmark.tags.map(&:label) }

    field :suggest, type: "completion", contexts: [ { name: :type, type: :category } ], value: ->(bookmark) {
      {
        input: [bookmark.title.downcase, bookmark.uri_string].concat(bookmark.tags.map(&:label)),
        contexts: {
          type: [:bookmark]
        }
      }
    }

    field :created_at, type: "date", include_in_all: false
  end

  define_type Tag do
    field :label, type: "keyword"
    field :suggest, type: "completion", contexts: [ { name: :type, type: :category } ], value: ->(tag) {
      {
        input: tag.label.downcase,
        contexts: {
          type: [ :tag ]
        }
      }
    }
  end
end
