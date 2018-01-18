class AdminController < ApplicationController
  layout "admin"

  before_action :require_admin

  protected

  def require_admin
    require_login
    render status: :not_found unless current_user.role? :admin
  end
end
