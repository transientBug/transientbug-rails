class Webpage < ApplicationRecord
  has_many :bookmarks

  # Serializes and deserializes a string as an Addressable::URI
  attribute :uri, :addressable_uri

  validates :uri, presence: true, uniqueness: true
end
