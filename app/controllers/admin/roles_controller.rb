# frozen_string_literal: true

class Admin::RolesController < AdminController
  layout "admin-tailwind"

  before_action :set_role, only: [:show, :edit, :update, :destroy]

  # GET /admin/roles
  def index
    role_table = Role.arel_table

    query_param = params[:q]
    base_where = role_table[:id].eq(query_param)
      .or(role_table[:name].matches("%#{ query_param }%"))
      .or(role_table[:description].matches("%#{ query_param }%"))

    @roles = Role.all
    @roles = @roles.where(base_where) if query_param.present? && !query_param.empty?
    @roles = @roles.order(name: :asc).page params[:page]

    @count = Role.count
  end

  # GET /admin/roles/new
  def new
    @role = Role.new
  end

  # POST /admin/roles
  def create
    @role = Role.new role_params

    return render :new, status: :bad_request unless @role.save

    redirect_to [:admin, @role], notice: "Role was successfully created."
  end

  # GET /admin/roles/1
  def show; end

  # GET /admin/roles/1/edit
  def edit; end

  # PATCH/PUT /admin/roles/1
  def update
    return render :edit, status: :bad_request unless @role.update role_params

    redirect_to [:admin, @role], notice: "Role was successfully updated."
  end

  # DELETE /admin/roles/1
  def destroy
    @role.destroy

    redirect_to admin_roles_url, notice: "Role was successfully destroyed."
  end

  private

  def set_role
    @role = Role.find params[:id]
  end

  def role_params
    params.require(:role).permit :name, :description, permission_keys: []
  end
end
