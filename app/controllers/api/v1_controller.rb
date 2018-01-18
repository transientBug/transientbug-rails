class Api::V1Controller < ApiController
  before_action :authenticate

  protected

  def authenticate
    @current_user = if params[:auth_token]
      email, token = params[:auth_token].split(":", 2)
      User.find_by(email: email)&.token_authenticate token
    else
      authenticate_or_request_with_http_basic do |email, password|
        User.find_by(email: email)&.authenticate password
      end
    end

    render_unauthorized "Invalid API Credentials" unless @current_user
  end

  def render_unauthorized message
    payload = { errors: [ { detail: message } ] }
    render json: payload, status: :unauthorized
  end
end
