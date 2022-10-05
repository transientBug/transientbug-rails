# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  title      :text
#  tags       :text             default("{}"), is an Array
#  source     :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  disabled   :boolean          default("false")
#
# Indexes
#
#  index_images_on_user_id  (user_id)
#

class Image < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  has_one_attached :image
end
