# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id         :bigint           not null, primary key
#  disabled   :boolean          default("false")
#  source     :text
#  tags       :text             default("{}"), is an Array
#  title      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_images_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Image < ApplicationRecord
  belongs_to :user

  validates :title, presence: true

  has_one_attached :image
end
