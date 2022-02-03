# frozen_string_literal: true

class Admin::Users::PasswordController < AdminController
  before_action :set_user

  # GET /admin/users/1/password
  def index; end

  # POST /admin/users/1/password
  def create
    return render :index, status: :bad_request unless @user.update password_params

    redirect_to admin_user_path(@user), notice: "Password updated."
  end

  private

  def set_user
    @user = User.find params[:user_id]
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
