# frozen_string_literal: true

class Admin::UsersController < AdminController
  before_action :set_user, only: [:show, :edit, :update]

  # GET /admin/users
  def index
    user_table = User.arel_table

    query_param = params[:q]
    base_where = user_table[:id].eq(query_param)
      .or(user_table[:username].matches("%#{ query_param }%"))
      .or(user_table[:email].matches("%#{ query_param }%"))

    @users = User.all
    @users = @users.where(base_where) if query_param.present? && !query_param.empty?
    @users = @users.order(created_at: :desc).page params[:page]

    @count = User.count
  end

  # GET /admin/users/new
  def new
    @user = User.new
  end

  # POST /admin/users
  def create
    @user = User.new new_user_params

    return render :new, status: :bad_request unless @user.save

    redirect_to [:admin, @user], notice: "User was successfully created."
  end

  # GET /admin/users/1
  def show; end

  # GET /admin/users/1/edit
  def edit; end

  # PATCH/PUT /admin/users/1
  def update
    return render :edit, status: :bad_request unless @user.update edit_user_params

    redirect_to [:admin, @user], notice: "User was successfully updated."
  end

  private

  def set_user
    @user = User.find params[:id]
  end

  def role_models
    params[:user].fetch(:role_ids, []).map(&:strip).reject(&:empty?).map do |role_id|
      Role.find_by(id: role_id)
    end
  end

  def new_user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation).tap do |obj|
      obj.merge!(roles: role_models)
    end
  end

  def edit_user_params
    params.require(:user).permit(:username, :email).tap do |obj|
      obj.merge!(roles: role_models) unless @user == current_user
    end
  end
end
