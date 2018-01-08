class ProfileController < ApplicationController
  require_login!
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update user_params
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end
end
