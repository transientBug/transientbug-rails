class OfflineCache < ApplicationRecord
  belongs_to :webpage

  has_and_belongs_to_many :bookmarks
  has_and_belongs_to_many :error_messages

  belongs_to :root, class_name: "ActiveStorage::Attachment", optional: true

  has_many_attached :assets
end
