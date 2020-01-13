class PagesController < ApplicationController
  layout "page"

  def main
    puts request.cookies.to_json
    puts response.cookies.to_json
    redirect_to :home if signed_in?
  end

  def faq; end

  def privacy; end

  def tos; end
end
