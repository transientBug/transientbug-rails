# frozen_string_literal: true

class Oauth::AuthorizationsController < Doorkeeper::AuthorizationsController
  include PreviousRedirectStorage
  include CurrentUser

  layout "page"

  require_login!
end
