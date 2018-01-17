class AdminController < ApplicationController
  include Pundit

  layout "admin"

  before_action :require_login
  before_action :require_admin

  helper_method :current_user, :signed_in?

  protected

  def require_admin
    render status: :not_found unless current_user.role? :admin
  end
end
