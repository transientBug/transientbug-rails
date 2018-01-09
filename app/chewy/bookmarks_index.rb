class BookmarksIndex < Chewy::Index
   settings analysis: {
    analyzer: {
      title: {
        tokenizer: :standard,
        filter: [:lowercase, :trim, :edgeNGram3x6]
      },
      description: {
        tokenizer: :standard,
        filter: [:lowercase, :trim, :edgeNGram3x6]
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
    field :title, type: "text", term_vector: "yes", analyzer: :title
    field :description, type: "text", analyzer: :description

    field :tags, type: "text", analyzer: :tag, value: ->(bookmark) { bookmark.tags.map(&:label) }
    field :uri, type: "keyword", value: ->(bookmark) { bookmark.webpage.uri_string }

    field :suggest, type: "completion", contexts: [ { name: :type, type: :category } ], value: ->(bookmark) {
      {
        input: [bookmark.title.downcase, bookmark.webpage.uri_string].concat(bookmark.tags),
        contexts: {
          type: [:bookmark]
        }
      }
    }

    field :created_at, type: "date", include_in_all: false
  end
end
