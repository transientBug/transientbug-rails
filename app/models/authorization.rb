class Authorization < ApplicationRecord
  belongs_to :user

  validates_presence_of :user_id, :uid, :provider
  validates_uniqueness_of :uid, scope: :provider

  def self.find_or_create_from_auth_hash auth_hash, user: nil
    auth = find_by provider: auth_hash['provider'], uid: auth_hash['uid']
    return auth if auth

    user ||= User.create_from_auth_hash! auth_hash

    info = auth_hash['info']
    creds = auth_hash['credentials']

    Authorization.create(
      user: user,
      provider: auth_hash['provider'],
      uid: auth_hash['uid'],
      name: info['name'],
      nickname: info['nickname'],
      email: info['email'],
      image: info['image'],
      token: creds['token'],
      secret: creds['secret'],
      expires: creds['expires'],
      expires_at: creds['expires_at']
    )
  end
end
