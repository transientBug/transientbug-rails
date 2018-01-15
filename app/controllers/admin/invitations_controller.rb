class Admin::InvitationsController < AdminController
  before_action :set_count
  before_action :set_invitation, only: [:show, :edit, :update, :destroy]

  # GET /invitations
  def index
    @invitations = Invitation.all.order(created_at: :desc).page params[:page]
  end

  # GET /invitations/1
  def show
    respond_to do |format|
      format.html { render :show }
    end
  end

  # GET /invitations/new
  def new
    @invitation = Invitation.new
  end

  # GET /invitations/1/edit
  def edit
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
    params.require(:invitation).permit(:code, :internal_note, :title, :description, :limit)
  end
end

