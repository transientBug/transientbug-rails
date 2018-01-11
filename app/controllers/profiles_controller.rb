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
        format.html { redirect_to profile_path, notice: "Profile updated" }
      else
        format.html { render :show }
      end
    end
  end

  # POST /profile/password
  def password
    unless @user.authenticate params.dig(:user, :current_password)
      respond_to do |format|
        format.html do
          flash.now[:error] = "Current password was incorrect, password not updated"
          render :show
        end
      end

      return
    end

    respond_to do |format|
      if @user.update password_params
        format.html { redirect_to profile_path, notice: "Password updated" }
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
    params.require(:user).permit(:username, :email)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
