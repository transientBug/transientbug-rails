class Invitation < ApplicationRecord
  has_many :invitations_users
  has_many :users, through: :invitation_users

  before_create :gen_code

  private

  def gen_code
    self.code ||= SecureRandom.hex(4)
  end
end
