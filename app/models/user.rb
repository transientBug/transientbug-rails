class User < ApplicationRecord
  default_scope { includes(:roles) }

  has_many :authorizations
  has_and_belongs_to_many :roles
  has_many :permissions, through: :roles

  has_many :images
  has_many :bookmarks
  has_many :searches

  has_many :import_data

  has_many :oauth_applications, class_name: "Doorkeeper::Application", as: :owner

  validates :username, presence: true
  validates :email, presence: true

  has_secure_password

  before_create :set_auth_token

  def self.find_or_create_from_auth_hash! auth_hash
    email = auth_hash.dig "info", "email"

    fail "Provider #{ auth_hash['provider'] } does not provide an email!" unless email.present?

    find_by email: email
    # find_or_create_by email: email do |user|
    #   user.username = auth_hash.dig 'info', 'name'
    # end
  end

  def self.generate_unique_secure_token
    SecureRandom.uuid
  end

  def regenerate_auth_token
    update! auth_token: self.class.generate_unique_secure_token
  end

  # The token that should be sent to the clients, hashed with a pepper because
  # just getting a hold of the database wouldn't result in a compromised API
  # Key unless they also got the secret.
  def api_token
    Digest::SHA256.hexdigest "#{ auth_token }#{ pepper }"
  end

  # Similar to has_secure_password's #authenticate, this tries to do a time
  # constant comparison. Digesting both tokens before hand ensures that both
  # strings are the same length during comparison. Suppose something could be
  # done to store the digest instead, but that'd require overriding
  # .has_secure_token
  def token_authenticate user_sent_token
    user_digest = ::Digest::SHA256.hexdigest "#{ auth_token }#{ pepper }"

    return false unless user_sent_token.bytesize == user_digest.bytesize
    ActiveSupport::SecurityUtils.secure_compare(user_sent_token, user_digest) && self
  end

  def owner_of? record
    return record.owner == self if record.respond_to? :owner
    return record.user_id == id if record.respond_to? :user_id
    false
  end

  def role? name
    roles.find { |role| role.name == name.to_s }
  end

  def has_permission? key
    permissions.find { |permission| permission.key == key.to_s }
  end

  private

  def set_auth_token
    self.auth_token ||= self.class.generate_unique_secure_token
  end

  def pepper
    Rails.application.credentials.auth_token_pepper
  end
end
