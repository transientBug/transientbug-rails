class AdminController < ApplicationController
  include Pundit

  layout "admin"

  protect_from_forgery with: :exception

  before_action :require_login
  before_action :require_admin

  protected

  def require_login
    redirect_to login_path unless signed_in?
  end

  def require_admin
    redirect_to root_path unless current_user.role? :admin
  end

  def current_user
    @current_user ||= User.find_by id: session[:user_id]
  end

  def signed_in?
    current_user.present?
  end

  helper_method :current_user, :signed_in?

  def current_user= user
    @current_user = user
    session[:user_id] = user&.id
  end
end
