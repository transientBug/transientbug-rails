class SessionsController < ApplicationController
  layout "page"

  before_action :redirect_home, only: [ :index, :new ], if: :signed_in?

  require_login! only: [ :destroy ]

  def index; end

  def new
    @user = User.find_by(email: params[:email])&.authenticate params[:password]

    return redirect_to login_url, notice: "Unable to log you in!" unless @user.present?

    self.current_user = @user

    redirect_to stored_location_for(:user) || home_url
  end

  def destroy
    self.current_user = nil
    request.reset_session

    redirect_to root_url
  end

  protected

  def redirect_home
    redirect_to root_url
  end
end
