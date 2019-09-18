class CspViolationReportController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.warn <<~MSG
      CSP Violation

      #{ csp_report }
    MSG

    head :ok
  end

  private

  def csp_report
    JSON.parse request.body.read
  end
end
