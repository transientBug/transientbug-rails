class Admin::InvitationsController < AdminController
  before_action :set_invitation, only: [:show, :edit, :update, :destroy]

  def index
  end

  def new
    @invitation = Inviation.new
  end

  def create
    @invitation = Inviation.new invitation_params
  end

  def show
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def set_invitation
    @invitiation = Invitation.find params[:id]
  end

  def invitation_params
    params.require(:invitation).permit(:code, :internal_note, :title, :description, :limit)
  end
end
