class Admin::InvitationsController < AdminController
  before_action :set_count
  before_action :set_invitation, only: [:show, :edit, :update, :destroy]

  # GET /invitations
  def index
    invitation_table = Invitation.arel_table

    query_param = params[:q]
    base_where = invitation_table[:id].eq(query_param)
      .or(invitation_table[:code].eq(query_param))
      .or(invitation_table[:internal_note].matches("%#{ query_param }%"))
      # .or(invitation_table[:title].matches("%#{ query_param }%"))

    @invitations = Invitation.all
    @invitations = @invitations.where(base_where) if query_param.present? && !query_param.empty?
    @invitations = @invitations.order(created_at: :desc).page params[:page]
  end

  # GET /invitations/1
  def show
  end

  # GET /invitations/new
  def new
    @invitation = Invitation.new
  end

  # POST /invitations
  def create
    @invitation = Invitation.new invitation_params

    respond_to do |format|
      if @invitation.save
        format.html { redirect_to [:admin, @invitation], notice: "Invitation was successfully created." }
      else
        format.html { render :new }
      end
    end
  end

  # GET /invitations/1/edit
  def edit
  end

  # PATCH/PUT /invitations/1
  def update
    respond_to do |format|
      if @invitation.update(invitation_params)
        format.html { redirect_to [:admin, @invitation], notice: "Invitation was successfully updated." }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /invitations/1
  def destroy
    respond_to do |format|
      if @invitation.destroy
        format.html { redirect_to admin_invitations_url, notice: "Invitation was successfully deleted." }
      else
        format.html { render :new }
      end
    end
  end

  private

  def set_invitation
    @invitation = Invitation.find params[:id]
  end

  def set_count
    @count = Invitation.count
  end

  def invitation_params
    params.require(:invitation).permit(:code, :internal_note, :title, :description, :available)
  end
end

