class ApplicationController < ActionController::Base
  include Pundit

  include PreviousRedirectStorage
  include CurrentUser

  protect_from_forgery with: :exception
end
