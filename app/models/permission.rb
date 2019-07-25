class Permission < ApplicationRecord
  validates_presence_of :name
  validates_presence_of :key
end
