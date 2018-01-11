class InvitesController < ApplicationController
  before_action :set_invite, only: [ :show, :update ]
  before_action :attempt_reservation, only: [ :show, :update ]
  before_action :no_loggedin

  def show
    redirect_to home_path, notice: "That invite isn't valid :(" and return unless @invitation

    attempt_reservation

    redirect_to home_path, notice: "That invite isn't valid :(" and return unless @invitations_user

    session[:invite_reservation] = @invitations_user.id

    @user = User.new
  end

  def update
    @user = User.new user_params

    if user.save
      @invitations_user.update user: @user
      self.current_user = @user
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
    @invitation = Invitation.find_by code: params[:id]
  end

  def attempt_reservation
    @invitations_user = @invitation.invitations_users.find_by id: session[:invite_reservation]
    @invitations_user ||= Invitation.transaction do
      @invitation.with_lock("FOR NO KEY UPDATE") do
        query = <<~SQL
          INSERT INTO invitations_users (invitation_id, created_at, updated_at)
          SELECT $1, NOW(), NOW()
          FROM invitations_users
          WHERE invitation_id = $1
          HAVING count(*) < $2
          RETURNING id;
        SQL

        result = ActiveRecord::Base.connection.raw_connection.exec_params(query, [@invitation.id.to_s, @invitation.limit.to_s])
        @invitation.invitations_users.find_by id: result.to_a.first&.fetch("id")
      end
    end
  end
end
