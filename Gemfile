source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Base Rails stuff
gem "rails", "~> 6.1"
gem "rake"
gem "bootsnap", require: false

# Data Stores
#  * Postgres
#  * Elasticsearch
#  * Redis
gem "pg"
gem "chewy"
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
gem "view_component", require: "view_component/engine"
gem "turbo-rails"

gem "inline_svg"

# Javascript and CSS
gem "webpacker"#, "~> 4.0"
gem "turbolinks"#, "~> 5"

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
gem "mimemagic"
gem "parslet"

gem "exception_notification"
gem "slack-notifier"

# API Documentation from RAD
gem "apitome", github: "jejacks0n/apitome"

gem "annotate"

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console"#, ">= 3.3.0"
  gem "listen"#, ">= 3.0.5", "< 3.2"

  gem "better_errors"
  gem "binding_of_caller"

end

group :development, :test do
  # Runner & Environment
  gem "foreman"
  gem "dotenv-rails"

  # Better Debugging
  gem "awesome_print"
  gem "byebug"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"

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
  gem "capybara"#, "~> 2.13"
  gem "capybara-selenium"
  gem "selenium-webdriver"
  # gem "chromedriver-helper"

  # Test rack things
  gem "rack-test"#, "~> 0.7.0"

  # A Mockery of Requests
  gem "webmock"

  # Coverage reports
  gem "simplecov", require: false

  # Cleanup
  gem "database_cleaner"

  # Check things
  gem "rubocop", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-rails", require: false
end
