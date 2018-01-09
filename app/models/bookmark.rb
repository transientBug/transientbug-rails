class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :webpage

  has_and_belongs_to_many :tags

  after_create :schedule_cache

  default_scope { includes(:webpage) }

  delegate :uri_string, to: :webpage
  delegate :uri, to: :webpage

  update_index("bookmarks#bookmark") { self }

  private

  def schedule_cache
    WebpageCacheJob.perform_later bookmark: self
  end
end
