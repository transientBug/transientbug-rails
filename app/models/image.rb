class Image < ApplicationRecord
  belongs_to :user

  validates_presence_of :title

  has_one_attached :image

  update_index("images#image") { self }
end
