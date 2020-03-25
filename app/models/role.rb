class Role < ApplicationRecord
  has_and_belongs_to_many :permissions

  validates_presence_of :name
end
