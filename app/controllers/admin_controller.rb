class AdminController < ApplicationController
  layout "admin"

  require_login!
  before_action :require_admin

  protected

  def require_admin
    render status: :not_found unless current_user.role? :admin
  end
end
