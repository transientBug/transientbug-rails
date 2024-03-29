require_relative "boot"

require "rails/all"
require 'good_job/engine'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

class FrameOption
  def initialize app
    @app = app
  end

  def call env
    status, headers, response = @app.call(env)

    # YOLO
    headers["X-Frame-Options"] = "SAMEORIGIN"
    headers["X-FRAME-OPTIONS"] = "SAMEORIGIN"
    headers["x-frame-options"] = "SAMEORIGIN"

    [status, headers, response]
  end
end

module TransientBug
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.generators do |g|
      g.assets = false
      g.helper = false
      g.stimulus = true
      g.template_engine = "erb"
      g.sidecar = true
    end

    config.exceptions_app = routes

    config.active_storage.draw_routes = false

    config.action_cable.mount_path = "/websocket"
    config.action_cable.url = "/websocket"
    config.action_cable.allowed_request_origins = ["https://staging.transientbug.ninja", "https://transientbug.ninja"]

    config.middleware.use FrameOption

    # Enable by setting the env GOOD_JOB_ENABLE_CRON=true
    config.good_job.cron = {
      # example: { cron: '0 * * * *', class: 'ExampleJob'  }
    }
  end
end
