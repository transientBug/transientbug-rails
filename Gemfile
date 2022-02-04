source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.0"

# Base Rails stuff
gem "rails", "~> 7"
gem "bootsnap", require: false

# Data Stores
#  * Postgres
#  * Elasticsearch
#  * Redis
gem "pg"
# gem "pg_search"
gem "redis"#, "~> 3.0"
gem "hiredis"
gem "connection_pool"
# gem "active_record_upsert" # Has issues with arel deps wnd the rails 5.2 beta

# Temp for image exports
# gem "sequel"
# gem "sqlite3"

# gem "aws-sdk-s3", "~> 1"

# Caching - Rails 5.2 shipped with a redis cache for fragments, but doesn't
# provide session storage via redis too, which redis-actionpack does.
gem "redis-actionpack"
gem "redis-rack-cache"

# CORS & other Security
gem "rack-cors"
gem "rack-attack"

# Needed for has_secure_password
gem "bcrypt"

# Server
gem "puma"#, "~> 3.11"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data"

# Views
gem "haml"
gem "haml-rails"
gem "view_component"

gem "inline_svg"

# Javascript and CSS
# gem "webpacker"#, "~> 4.0"
gem "jsbundling-rails"
gem "cssbundling-rails"

gem "sprockets-rails"
gem "turbo-rails"
gem "stimulus-rails"

# Better link styling
gem "active_link_to"

# Pagination
gem "kaminari"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder"

# ActiveJob Worker
gem "sidekiq"

# Logs
gem "logster"

# Cron like scheduled/repeating tasks
# gem "clockwork"

# Auth
# Provider
gem "doorkeeper"
# Consumer
# gem "omniauth-rails_csrf_protection"
# gem "omniauth-apple"
# gem "omniauth-twitter"
# gem "omniauth-github"

# Permissions
gem "pundit", github: "elabs/pundit"

# Request making
gem "http"
gem "addressable"
# gem "robotstxt-parser", require: "robotstxt"

# Parsing/HTML handling
gem "nokogiri"
# gem "loofah"
# gem "ruby-readability"
# gem "stopwords-filter"
gem "marcel", "~> 1.0"
gem "parslet"

gem "exception_notification"
gem "slack-notifier"

# API Documentation from RAD
# gem "apitome", github: "jejacks0n/apitome"
gem "raddocs"

gem "annotate"

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console"#, ">= 3.3.0"
  gem "listen"#, ">= 3.0.5", "< 3.2"

  # gem "better_errors"
  # gem "binding_of_caller"
end

group :development, :test do
  # Runner & Environment
  gem "foreman"
  gem "dotenv-rails"

  # Better Debugging
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  # gem "awesome_print"
  # gem "byebug"
  # gem "pry"
  # gem "pry-byebug"
  # gem "pry-rails"

  # Document everything
  gem "yard"#, ">= 0.9.20"

  # Test everything
  gem "rspec"
  gem "rspec-rails", "~> 4.0.0"

  # Build out better factories than the yaml fixtures
  gem "factory_bot_rails"

  # Auto-runners for tests and docs
  gem "guard"
  gem "guard-yard"
  gem "guard-rspec"

  # Handle mail intercepting in development
  gem "mailcatcher"

  # Document the API through rspec tests
  gem "rspec_api_documentation"
  gem "json_matchers"#, "~> 0.9"
end

group :test do
  # Adds support for Capybara system testing and selenium driver with headless
  # chrome
  # gem "capybara"#, "~> 2.13"
  # gem "capybara-selenium"
  # gem "selenium-webdriver"
  # gem "chromedriver-helper"

  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"

  # Test rack things
  gem "rack-test"#, "~> 0.7.0"

  # A Mockery of Requests
  gem "webmock"

  # Coverage reports
  gem "simplecov", require: false

  # Cleanup
  gem "database_cleaner"
end

group :test, :development, :ci do
  # Check things
  gem "rubocop", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rails", require: false
end
