# frozen_string_literal: true

# == Schema Information
#
# Table name: bookmarks
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  webpage_id     :integer
#  title          :text
#  description    :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  uri            :text             default(""), not null
#  search_title   :tsvector
#  uri_breakdowns :text             default("{}"), is an Array
#
# Indexes
#
#  index_bookmarks_on_search_title            (search_title)
#  index_bookmarks_on_uri                     (uri)
#  index_bookmarks_on_uri_breakdowns          (uri_breakdowns)
#  index_bookmarks_on_user_id                 (user_id)
#  index_bookmarks_on_user_id_and_webpage_id  (user_id,webpage_id) UNIQUE
#  index_bookmarks_on_webpage_id              (webpage_id)
#

class Bookmark < ApplicationRecord
  belongs_to :user

  has_many :bookmarks_tags
  has_many :tags, through: :bookmarks_tags

  has_many :offline_caches

  after_create_commit :schedule_cache

  before_save :set_uri_breakdowns

  # Temp disable while transitioning the uri to bookmarks from webpages
  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :uri, presence: true, uniqueness: { scope: :user_id }
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  scope :tag_search, ->(query) { where(tags: { label: query }) }
  scope :uri_search, ->(query) { where(arel_table[:uri].matches("%#{ query }%")) }
  scope :breakdown_search, lambda { |query|
    any_host = Arel::Nodes::NamedFunction.new("ANY", [arel_table[:uri_breakdowns]])
    where(Arel::Nodes.build_quoted(query).eq(any_host))
  }

  # Searches the title for the query OR where the query is similar to
  # words in an existing bookmark's title
  scope :title_search, ->(query) { where(<<~SQL.squish, { query: }) }
    search_title @@ websearch_to_tsquery(:query)
    OR search_title @@ to_tsquery(
      SELECT
        word
      FROM ts_stat('SELECT search_title FROM bookmarks')
      WHERE similarity(:query, word) > 0.5
      ORDER BY similarity(:query, word) DESC
      LIMIT 1
    )
  SQL

  scope :search, lambda { |query|
    joins(:tags)
      .uri_search(query)
      .or(breakdown_search(query))
      .or(title_search(query))
      .or(tag_search(query))
  }

  scope :advanced_search, lambda { |query|
    BookmarksSearcher.new.search query
  }

  # This has potential performance costs if we start retrying lots of times
  def self.for(user, uri)= find_or_initialize_by(user:, uri:)

  def upsert
    save
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    existing = find_by user: user, uri: uri
    existing.update attributes.slice("title", "description").merge(tags:)
    existing
  end

  def current_offline_cache()= offline_caches.last

  def to_addressable()= Addressable::URI.parse(uri).omit(:fragment)

  protected

  def schedule_cache()= WebpageCacheJob.perform_later(bookmark: self)

  def set_uri_breakdowns()= self.uri_breakdowns = build_uri_iterations

  def build_uri_iterations
    host = to_addressable.host
    host_iterations = [ host ].compact

    return host_iterations unless host

    loop do
      break if host.count(".") < 1

      host = host.split(".", 2).last
      host_iterations << host
    end

    host_iterations.compact
  end
end
