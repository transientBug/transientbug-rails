class ProfilesController < ApplicationController
  require_login!
  before_action :set_user

  # GET /profile
  def show
  end

  # PATCH /profile
  # PUT /profile
  def update
    respond_to do |format|
      if @user.update user_params
        format.html { redirect_to profile_path, notice: "Profile Updated" }
      else
        format.html { render :show }
      end
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
