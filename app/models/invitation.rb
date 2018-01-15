class Invitation < ApplicationRecord
  has_many :invitations_users
  has_many :users, through: :invitation_users

  after_initialize :gen_code
  after_initialize :set_current

  private

  def gen_code
    self.code ||= SecureRandom.hex(4)
    self.limit ||= 1
  end

  def set_current
    self.current ||= self.limit
  end
end
