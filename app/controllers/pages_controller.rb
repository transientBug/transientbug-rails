class PagesController < ApplicationController
  layout "page"

  def main
  redirect_to :home if signed_in?
  end

  def faq; end

  def privacy; end

  def tos; end
end
