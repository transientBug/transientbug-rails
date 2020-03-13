# frozen_string_literal: true

# == Schema Information
#
# Table name: permissions
#
#  id          :bigint           not null, primary key
#  description :string
#  key         :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_permissions_on_key  (key) UNIQUE
#
class Permission < ApplicationRecord
  validates :name, presence: true
  validates :key, presence: true
end
