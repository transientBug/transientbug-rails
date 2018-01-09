class User < ApplicationRecord
  has_many :authorizations
  has_many :images

  has_one :identity

  validates :username, presence: true
  validates :email, presence: true

  has_secure_password

  def self.find_or_create_from_auth_hash! auth_hash
    email = auth_hash.dig 'info', 'email'

    fail "Provider #{ auth_hash['provider'] } does not provide an email!" unless email.present?

    find_by email: email
    # find_or_create_by email: email do |user|
      # user.username = auth_hash.dig 'info', 'name'
    # end
  end

  def owner_of? record
    record.user_id == self.id
  end
end
