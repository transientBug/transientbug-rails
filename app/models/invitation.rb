class Invitation < ApplicationRecord
  has_many :invitations_users
  has_many :users, through: :invitation_users

  after_initialize :gen_code

  private

  def gen_code
    self.code ||= SecureRandom.hex(4) # TODO: Make this safer since codes are unique
  end
end
