module CurrentUser
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?
  end

  class_methods do
    def require_login! **opts
      before_action :store_user_location!, if: :storable_location?
      before_action :require_login, **opts, unless: :signed_in?
    end
  end

  protected

  def require_login
    redirect_to login_url
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
end