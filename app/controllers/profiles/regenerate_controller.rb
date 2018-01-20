class Profiles::RegenerateController < ApplicationController
  require_login!
  before_action :set_user

  def update
    respond_to do |format|
      if @user.regenerate_auth_token
        format.html { redirect_to profile_path, notice: "API Token Regenerated!" }
      else
        format.html { render "profiles/show" }
      end
    end
  end

  protected

  def set_user
    @user = current_user
  end
end
