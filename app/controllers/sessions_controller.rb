class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  skip_before_action :require_login, only: :create

  # https://seesparkbox.com/foundry/simulating_social_login_with_omniauth
  def create
    @auth = Authorization.find_or_create_from_auth_hash(auth_hash, user: current_user)

    # TODO: Handle not found
    self.current_user = @auth.user

    redirect_to request.env['omniauth.origin'] || home_url
  end

  def destroy
    self.current_user = nil
    redirect_to root_url
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
