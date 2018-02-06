class Admin::UsersController < AdminController
  before_action :set_count
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
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

  # GET /users/1
  def show
    respond_to do |format|
      format.html { render :show }
    end
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to [:admin, @user], notice: "User was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  private

  def set_user
    @user = User.find params[:id]
  end

  def set_count
    @count = User.count
  end

  def user_params
    params.require(:user).permit(:username, :email).tap do |obj|
      roles = params.dig(:user).fetch(:role_ids, []).map(&:strip).reject(&:empty).map do |role_id|
        Role.find_by(id: role_id)
      end

      obj.merge!(roles: roles)
    end
  end
end

