# frozen_string_literal: true

# == Schema Information
#
# Table name: invitations
#
#  id            :integer          not null, primary key
#  code          :text
#  internal_note :text
#  title         :text
#  description   :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  available     :integer          default("1")
#
# Indexes
#
#  index_invitations_on_code  (code) UNIQUE
#

class Invitation < ApplicationRecord
  has_many :invitations_users
  has_many :users, through: :invitation_users

  after_initialize :gen_code

  private

  def gen_code
    self.code ||= SecureRandom.hex(4) # TODO: Make this safer since codes are unique
  end
end
