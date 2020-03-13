# frozen_string_literal: true

# == Schema Information
#
# Table name: webpages
#
#  id         :bigint           not null, primary key
#  uri        :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_webpages_on_uri  (uri) UNIQUE
#
class Webpage < ApplicationRecord
  has_many :bookmarks
  has_many :offline_caches

  # Serializes and deserializes a string as an Addressable::URI
  attribute :uri, :addressable_uri

  validates :uri, presence: true, uniqueness: true
end
