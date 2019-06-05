class SessionsController < ApplicationController
  before_action :redirect_home, only: [ :index, :new ], if: :signed_in?

  require_login! only: [ :destroy ]

  # Oauth clients aren't going to be sending along an authenticity token since they're
  # external clients
  skip_before_action :verify_authenticity_token, only: :create

  def index; end

  def new
    @user = User.find_by(email: params[:email])&.authenticate params[:password]

    return redirect_to login_url, notice: "Unable to log you in!" unless @user.present?

    self.current_user = @user

    redirect_to stored_location_for(:user) || home_url
  end

  # https://seesparkbox.com/foundry/simulating_social_login_with_omniauth
  def create
    @auth = Authorization.find_or_create_from_auth_hash(auth_hash, user: current_user)

    return redirect_to home_url, notice: "Unable to log you in!" unless @auth.present?

    # TODO: Handle not found
    self.current_user = @auth.user

    redirect_to request.env["omniauth.origin"] || stored_location_for(:user) || home_url
  end

  def destroy
    self.current_user = nil
    request.reset_session

    redirect_to root_url
  end

  protected

  def auth_hash
    request.env["omniauth.auth"]
  end

  def redirect_home
    redirect_to root_url
  end
end
