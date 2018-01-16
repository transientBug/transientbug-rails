class Admin::UsersController < AdminController
  before_action :set_count
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  def index
    @users = User.all.order(created_at: :desc).page params[:page]
  end

  # GET /users/1
  def show
    respond_to do |format|
      format.html { render :show }
    end
  end

  # GET /users/new
  # def new
  #   @user = User.new
  # end

  # POST /users
  # def create
  #   @user = User.new user_params

  #   respond_to do |format|
  #     if @user.save
  #       format.html { redirect_to [:admin, @user], notice: "User was successfully created." }
  #     else
  #       format.html { render :new }
  #     end
  #   end
  # end

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

  # DELETE /users/1
  # def destroy
  #   respond_to do |format|
  #     if @user.destroy
  #       format.html { redirect_to admin_users_url, notice: "User was successfully deleted." }
  #     else
  #       format.html { render :new }
  #     end
  #   end
  # end

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

