# frozen_string_literal: true

# == Schema Information
#
# Table name: bookmarks
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  webpage_id  :integer
#  title       :text
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_bookmarks_on_user_id                 (user_id)
#  index_bookmarks_on_user_id_and_webpage_id  (user_id,webpage_id) UNIQUE
#  index_bookmarks_on_webpage_id              (webpage_id)
#

class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :webpage

  has_many :bookmarks_tags
  has_many :tags, through: :bookmarks_tags

  has_and_belongs_to_many :offline_caches

  after_create_commit :schedule_cache

  default_scope { includes(:webpage) }

  delegate :uri, to: :webpage

  validates :webpage_id, uniqueness: { scope: :user_id }

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

  def schedule_cache
    WebpageCacheJob.perform_later bookmark: self
  end
end
