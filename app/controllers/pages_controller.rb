class PagesController < ApplicationController
  require_login! except: [ :main, :faq ]

  before_action :login_redirect, only: [ :main ]

  def main
  end

  def faq
  end

  def home
    @recent_bookmarks = policy_scope(Bookmark).limit(15)
  end

  def extension_pair
  end

  protected

  def login_redirect
    redirect_to home_path if signed_in?
  end
end
