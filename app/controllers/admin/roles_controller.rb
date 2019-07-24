class Admin::RolesController < AdminController
  before_action :set_count
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
  end

  # GET /admin/roles/new
  def new
    @role = Role.new
  end

  # POST /admin/roles
  def create
    @role = Role.new(role_params)

    respond_to do |format|
      if @role.save
        format.html { redirect_to [:admin,  @role], notice: 'Role was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # GET /admin/roles/1
  def show; end

  # GET /admin/roles/1/edit
  def edit; end

  # PATCH/PUT /admin/roles/1
  def update
    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to [:admin, @role], notice: 'Role was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /admin/roles/1
  def destroy
    @role.destroy
    respond_to do |format|
      format.html { redirect_to admin_roles_url, notice: 'Role was successfully destroyed.' }
    end
  end

  private

  def set_role
    @role = Role.includes(:permissions).find(params[:id])
  end

  def set_count
    @count = Role.count
  end

  def role_params
    params.require(:role).permit :name, :description, permission_ids: []
  end
end
