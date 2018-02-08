class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :webpage

  has_and_belongs_to_many :tags

  has_and_belongs_to_many :offline_caches

  after_save :schedule_cache

  default_scope { includes(:webpage) }

  delegate :uri, to: :webpage

  update_index("bookmarks#bookmark") { self }

  validates_uniqueness_of :webpage_id, scope: :user_id

  # This has potential performance costs if we start retrying lots of times
  def self.for user, uri
    webpage = Webpage.upsert uri: uri
    find_or_initialize_by user: user, webpage: webpage
  end

  def upsert
    save
  rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
    existing = find_by user: user, webpage: webpage
    existing.update attributes.slice("title", "description").merge(tags: tags)
    existing
  end

  def current_offline_cache
    offline_caches.last
  end

  private

  def schedule_cache
    WebpageCacheJob.perform_later bookmark: self
  end
end
