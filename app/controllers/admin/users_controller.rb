class Admin::UsersController < AdminController
  layout "admin-tailwind"

  before_action :set_count
  before_action :set_user, only: [:show, :edit, :update, :destroy]

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
  end

  # GET /admin/users/new
  def new
    @user = User.new
  end

  # POST /admin/users
  def create
    @user = User.new new_user_params

    unless @user.save
      headers["Location"] = new_admin_user_url
      return render :new, status: 400
    end

    redirect_to [:admin, @user], notice: "User was successfully created."
  end

  # GET /admin/users/1
  def show; end

  # GET /admin/users/1/edit
  def edit; end

  # PATCH/PUT /admin/users/1
  def update
    return render :edit unless @user.update edit_user_params

    redirect_to [:admin, @user], notice: "User was successfully updated."
  end

  private

  def set_user
    @user = User.find params[:id]
  end

  def set_count
    @count = User.count
  end

  def role_models
    params.dig(:user).fetch(:role_ids, []).map(&:strip).reject(&:empty?).map do |role_id|
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
