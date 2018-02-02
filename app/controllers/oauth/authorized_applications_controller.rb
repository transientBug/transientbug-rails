class Oauth::AuthorizedApplicationsController < ApplicationController
  require_login!

  def index
    @applications = policy_scope(Doorkeeper::Application).authorized_for(current_user).page params[:page]
  end

  def destroy
    Doorkeeper::AccessToken.revoke_all_for params[:id], current_user

    notice = "Application revoked"
    redirect_to oauth_authorized_applications_url, notice: notice
  end
end
