class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :webpage

  has_many :tags, through: :bookmarks_tags

  after_create :schedule_cache

  def schedule_cache
    CacheWebpageJob.perform_later bookmark: self
  end
end
