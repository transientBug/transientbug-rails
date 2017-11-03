require "omniauth-identity"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :identity
  # provider :twitter, ENV["TWITTER_KEY"], ENV["TWITTER_SECRET"]
end

OmniAuth.config.logger = Rails.logger
