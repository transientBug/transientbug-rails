class Image < ApplicationRecord
  belongs_to :user

  validates_presence_of :title

  has_one_attached :image

  update_index("images#image") { self }
  update_index("images#tag") { tags.map(&ImagesIndex::TagStruct.method(:from)) }
end
