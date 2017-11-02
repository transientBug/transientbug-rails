class PagesController < ApplicationController
  require_login! only: [ :home ]

  before_action :login_redirect, only: [ :main ]

  def main
    redirect_to images_path
  end

  def home
  end

  protected

  def login_redirect
    redirect_to home_path if signed_in?
  end
end
