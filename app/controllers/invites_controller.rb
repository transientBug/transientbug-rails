class InvitesController < ApplicationController
  before_action :no_loggedin

  before_action :set_invite, only: [ :create, :show, :update ]

  def index
  end

  def create
    redirect_to invite_path(@invitation.code)
  end

  def show
    @user = User.new
  end

  def update
    @user = User.new user_params

    if @user.save
      @invitations_user.update user: @user
      self.current_user = @user
      session.delete :invite_reservation
      redirect_to home_path, notice: "Welcome #{ @user.username }!"
    else
      render :show
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def no_loggedin
    redirect_to home_path if signed_in?
  end

  def set_invite
    @invitation = Invitation.find_by code: (params[:id] || params[:code])

    redirect_to invites_path, error: "That invite isn't valid :(" unless @invitation

    @invitations_user = @invitation.invitations_users.find_by id: session[:invite_reservation]

    return if @invitations_user

    query = <<~SQL
      UPDATE invitations
      SET available = available - 1
      WHERE available > 0
        AND id = $1
      RETURNING id, available
      ;
    SQL

    result = ActiveRecord::Base.connection.raw_connection.exec_params(query, [@invitation.id.to_s])

    row = result.to_a.first || {}

    redirect_to invites_path, error: "That invite isn't valid :(" if row["available"]&.negative?

    @invitations_user = @invitation.invitations_users.create
    session[:invite_reservation] = @invitations_user.id
  end
end
