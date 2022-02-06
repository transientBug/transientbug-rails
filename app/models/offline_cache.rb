# frozen_string_literal: true

# == Schema Information
#
# Table name: offline_caches
#
#  id          :integer          not null, primary key
#  webpage_id  :integer
#  root_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  bookmark_id :integer
#
# Indexes
#
#  index_offline_caches_on_bookmark_id  (bookmark_id)
#  index_offline_caches_on_root_id      (root_id)
#  index_offline_caches_on_webpage_id   (webpage_id)
#

class OfflineCache < ApplicationRecord
  belongs_to :bookmark
  has_and_belongs_to_many :error_messages

  belongs_to :root, class_name: "ActiveStorage::Attachment", optional: true

  has_many_attached :assets
end
