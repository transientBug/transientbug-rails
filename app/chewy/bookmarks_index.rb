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

  def self.build_host_iterations bookmark
    url = bookmark.uri.host
    host_iterations = [ url ]

    loop do
      break if url.count(".") < 1
      url = url.split(".", 2).last
      host_iterations << url
    end

    host_iterations
  end

  define_type Bookmark do
    field :uri, type: :keyword, value: ->(bookmark) { bookmark.uri.to_s }

    field :scheme, type: :keyword, value: ->(bookmark) { bookmark.uri.scheme }

    field :host, type: :keyword, value: ->(bookmark) { build_host_iterations bookmark }

    field :port, type: :integer, value: ->(bookmark) { bookmark.uri.port }
    field :path, type: :keyword, value: ->(bookmark) { bookmark.uri.path }
    field :query, type: :keyword, value: ->(bookmark) { bookmark.uri.query }
    field :fragment, type: :keyword, value: ->(bookmark) { bookmark.uri.fragment }

    field :title, type: :text, term_vector: :yes, analyzer: :title
    field :description, type: :text, analyzer: :description

    field :tags, type: :text, analyzer: :tag, value: ->(bookmark) { bookmark.tags.map(&:label) }

    field :user_id, type: :integer

    field :suggest, type: :completion, contexts: [ { name: :type, type: :category } ], value: ->(bookmark) {
      {
        input: [bookmark.title&.downcase, bookmark.uri.to_s].concat(bookmark.tags.map(&:label)),
        contexts: {
          type: [:bookmark]
        }
      }
    }

    field :created_at, type: :date, include_in_all: false
  end

  define_type Tag do
    field :label, type: :keyword

    field :suggest, type: :completion, contexts: [ { name: :type, type: :category } ], value: ->(tag) {
      {
        input: tag.label.downcase,
        contexts: {
          type: [ :tag ]
        }
      }
    }
  end
end
