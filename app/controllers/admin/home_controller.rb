class Admin::HomeController < AdminController
  layout "admin-tailwind"

  # GET /admin
  def home
    flash.now[:info] = "hia"
  end
end
