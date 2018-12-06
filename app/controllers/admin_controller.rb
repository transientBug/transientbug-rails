class AdminController < ApplicationController
  layout "admin"

  require_admin! # From CurrentUser concern
end
