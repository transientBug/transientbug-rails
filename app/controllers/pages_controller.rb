class PagesController < ApplicationController
  skip_before_action :require_login, only: [ :main ]
  before_action :login_redirect, only: [ :main ]

  def main
  end

  def home
  end

  protected

  def login_redirect
    redirect_to "/home" if signed_in?
  end
end
