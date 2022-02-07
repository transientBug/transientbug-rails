# frozen_string_literal: true

class ErrorsController < ApplicationController
  def not_found()= render(status: :not_found)

  def internal_server_error()= render(status: :internal_server_error)
end
