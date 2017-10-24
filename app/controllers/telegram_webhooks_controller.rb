class TelegramWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook

  def webhook
    bot = AutumnMoon.bots[params[:token]]
    render json: { status: "not_found", message: "we ain't found shit!" }, status: :not_found unless bot.present?

    bot.route params[:message].to_unsafe_h.deep_symbolize_keys
    render json: { status: "ok", message: "loud and clear, capcom" }, status: :ok
  end
end
