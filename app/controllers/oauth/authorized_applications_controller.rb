# frozen_string_literal: true

class Oauth::AuthorizedApplicationsController < ApplicationController
  layout "page"

  require_login!

  def index
    @applications = policy_scope(Doorkeeper::Application).authorized_for(current_user).page params[:page]
  end

  def destroy
    Doorkeeper::AccessToken.revoke_all_for params[:id], current_user

    redirect_to oauth_authorized_applications_url, notice: "Application revoked"
  end
end
