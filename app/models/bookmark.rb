class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :webpage

  has_and_belongs_to_many :tags

  after_save :schedule_cache

  default_scope { includes(:webpage) }

  delegate :uri_string, to: :webpage
  delegate :uri, to: :webpage

  update_index("bookmarks#bookmark") { self }

  validates_uniqueness_of :webpage_id, scope: :user_id

  # This has potential performance costs if we start retrying lots of times
  def self.for user, uri
    webpage = Webpage.upsert uri_string: uri
    bookmark = find_or_initialize_by user: user, webpage: webpage

    yield bookmark

    bookmark.tags = Tag.find_or_create_tags tags: bookmark.tags

    bookmark
  end

  def upsert
    save
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    existing = find_by user: user, webpage: webpage
    existing.update self.attributes.slice("title", "description").merge(tags: self.tags)
    existing
  end

  private

  def schedule_cache
    WebpageCacheJob.perform_later bookmark: self
  end
end
