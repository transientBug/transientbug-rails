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
  def self.find_or_create_for_user user:, uri_string:
    webpage = begin
                Webpage.find_or_create uri_string: uri_string
              rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation => e
                retry
              end

    begin
      webpage.bookmarks.find_of_create user: user
    rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation => e
      retry
    end
  end

  private

  def schedule_cache
    WebpageCacheJob.perform_later bookmark: self
  end
end
