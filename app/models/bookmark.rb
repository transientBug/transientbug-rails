class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :webpage

  has_many :tags, through: :bookmarks_tags
end
