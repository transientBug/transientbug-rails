require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TransientBug
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_job.queue_adapter = :sidekiq

    # This is needed because database cleaner is a dumbass and loads up EVERY
    # FUCKING ADAPTOR BECAUSE WHY NOT
    # https://github.com/DatabaseCleaner/database_cleaner/blob/07fa376c78014d69eb08d75346a4c715731448b0/lib/database_cleaner/active_record/truncation.rb#L7
    if Rails.version >= '5.1.0' && config.active_record.sqlite3.present?
      config.active_record.sqlite3.represent_boolean_as_integer = true
    end
  end
end
