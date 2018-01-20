class Api::V1Controller < ApiController
  include Pundit
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  before_action :authenticate

  helper_method :current_user

  protected

  def authenticate
    @current_user = token_auth if params[:auth_token]
    @current_user ||= basic_auth

    render_unauthorized "Invalid API Credentials" unless @current_user
  end

  def current_user
    @current_user
  end

  def render_unauthorized message
    payload = { errors: [ { detail: message } ] }
    render json: payload, status: :unauthorized
  end

  def token_auth
    email, token = params[:auth_token].split(":", 2)
    User.find_by(email: email)&.token_authenticate token
  end

  def basic_auth
    authenticate_or_request_with_http_basic do |email, password|
      User.find_by(email: email)&.authenticate password
    end
  end
end
