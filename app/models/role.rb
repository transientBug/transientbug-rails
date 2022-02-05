# frozen_string_literal: true

# == Schema Information
#
# Table name: roles
#
#  id              :integer          not null, primary key
#  name            :text             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  description     :string
#  permission_keys :string           default("{}"), not null, is an Array
#
# Indexes
#
#  index_roles_on_name  (name) UNIQUE
#

Permission = Struct.new :key, :name, :description

class Role < ApplicationRecord
  PERMISSIONS = [
    # Admin
    Permission.new("admin.access", "Access Admin Panel", "Access to the main admin panel"),
    Permission.new("admin.logs", "Access Admin Logs", "Access the admin logster view"),
    Permission.new("admin.sidekiq", "Access Admin Sidekiq", "Access the admin sidekiq panel")
  ].freeze

  PERMISSIONS_BY_KEY = PERMISSIONS.index_by(&:key).freeze

  before_validation :clean_permissions
  validates :name, presence: true, uniqueness: true
  validate :valid_permission_keys

  def permissions()= permission_keys.map(&Role::PERMISSIONS_BY_KEY.method(:[])).compact

  def permission? key
    fail "Unknown permission_key #{ key }" unless PERMISSIONS_BY_KEY.key? key

    permission_keys.include? key
  end

  protected

  def clean_permissions
    self.permission_keys = permission_keys.compact_blank
  end

  def valid_permission_keys
    permission_keys.each do |key|
      errors.add :permission_keys, message: "permission_key #{ key } is invalid" if PERMISSIONS_BY_KEY[key].blank?
    end
  end
end
