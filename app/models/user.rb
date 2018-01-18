class User < ApplicationRecord
  default_scope { includes(:roles) }

  has_many :authorizations
  has_and_belongs_to_many :roles

  has_many :images
  has_many :bookmarks

  validates :username, presence: true
  validates :email, presence: true

  has_secure_password
  has_secure_token :auth_token

  def self.find_or_create_from_auth_hash! auth_hash
    email = auth_hash.dig 'info', 'email'

    fail "Provider #{ auth_hash['provider'] } does not provide an email!" unless email.present?

    find_by email: email
    # find_or_create_by email: email do |user|
      # user.username = auth_hash.dig 'info', 'name'
    # end
  end

  # Similar to has_secure_password's #authenticate, this tries to do a time
  # constant comparison. Digesting both tokens before hand ensures that both
  # strings are the same length during comparison. Suppose something could be
  # done to store the digest instead, but that'd require overriding
  # .has_secure_token
  def token_authenticate token
    token_digest = ::Digest::SHA256.hexdigest token
    user_digest  = ::Digest::SHA256.hexdigest auth_token
    ActiveSupport::SecurityUtils.secure_compare(token_digest, user_digest) && self
  end

  def owner_of? record
    record.user_id == self.id
  end

  def role? name
    roles.find { |role| role.name == name.to_s }
  end
end
