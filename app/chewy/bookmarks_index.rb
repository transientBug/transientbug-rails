class BookmarksIndex < Chewy::Index
  settings analysis: {
    analyzer: {
      title: {
        tokenizer: :standard,
        filter: [:lowercase, :trim, :english_stop]
      },
      description: {
        tokenizer: :standard,
        filter: [:lowercase, :trim, :english_stop]
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

  class << self
    def build_host_iterations bookmark
      host = bookmark.uri.host
      host_iterations = [ host ].compact

      return host_iterations unless host

      loop do
        break if host.count(".") < 1
        host = host.split(".", 2).last
        host_iterations << host
      end

      host_iterations.compact
    end

    def build_bookmark_suggest bookmark
      {
        input: [bookmark.title&.downcase, bookmark.uri.to_s].concat(bookmark.tags.map(&:label)),
        contexts: {
          type: [:bookmark]
        }
      }
    end

    def build_tag_suggest tag
      {
        input: tag.label.downcase,
        contexts: {
          type: [ :tag ]
        }
      }
    end
  end

  define_type Bookmark do
    field :uri, type: :keyword, value: ->(bookmark) { bookmark.uri.to_s }

    field :scheme, type: :keyword, value: ->(bookmark) { bookmark.uri.scheme }

    field :host, type: :keyword, value: ->(b) { build_host_iterations b }

    field :port, type: :integer, value: ->(bookmark) { bookmark.uri.port }
    field :path, type: :keyword, value: ->(bookmark) { bookmark.uri.path }
    field :query, type: :keyword, value: ->(bookmark) { bookmark.uri.query }
    field :fragment, type: :keyword, value: ->(bookmark) { bookmark.uri.fragment }

    field :title, type: :text, term_vector: :yes, analyzer: :title
    field :description, type: :text, analyzer: :description

    field :tags, type: :keyword, value: ->(bookmark) { bookmark.tags.map(&:label) }

    field :user_id, type: :integer

    field :suggest,
          type: :completion,
          contexts: [ { name: :type, type: :category } ],
          value: ->(b) { build_bookmark_suggest b }

    field :created_at, type: :date, include_in_all: false
  end

  define_type Tag do
    field :label, type: :keyword

    field :suggest,
          type: :completion,
          contexts: [ { name: :type, type: :category } ],
          value: ->(t) { build_tag_suggest t }
  end
end
