class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception

  before_action :set_active_service_announcements

  helper_method :current_user, :signed_in?

  def self.require_login! **opts
    before_action :require_login, **opts
  end

  protected

  def require_login
    redirect_to root_url unless signed_in?
  end

  def current_user
    @current_user ||= User.find_by id: session[:user_id]
  end

  def signed_in?
    current_user.present?
  end

  def current_user= user
    @current_user = user
    session[:user_id] = user&.id
  end

  def set_active_service_announcements
    @active_service_announcements = ServiceAnnouncement.active
  end
end
