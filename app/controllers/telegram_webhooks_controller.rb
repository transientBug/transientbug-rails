class TelegramWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook

  def webhook
    bot = AutumnMoon.bots[params[:token]]
    render json: { status: "not_found", message: "we ain't found shit!" }, status: :not_found unless bot.present?

    AsyncMoonJob.perform_later params[:token], params[:telegram_webhook].to_unsafe_h
    render json: { status: "ok", message: "loud and clear, capcom" }, status: :ok
  end
end
