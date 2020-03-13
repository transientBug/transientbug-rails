# frozen_string_literal: true

module CurrentUser
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?, :render_not_found
  end

  class_methods do
    def require_login! **opts
      before_action :store_user_location!, if: :storable_location?
      before_action :render_not_found, **opts, unless: :signed_in?
    end

    def require_admin! **opts
      before_action :store_user_location!, if: :storable_location?
      before_action :render_not_found, **opts, unless: :admin?
    end
  end

  protected

  def render_not_found
    render "errors/not_found", status: :not_found, layout: "application"
  end

  def current_user
    @current_user ||= User.find_by id: session[:user_id]
  end

  def signed_in?
    current_user.present?
  end

  def admin?
    signed_in? && current_user&.role?(:admin)
  end

  def current_user= user
    @current_user = user
    session[:user_id] = user&.id
  end
end
