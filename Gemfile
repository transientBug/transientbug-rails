source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Base Rails stuff
gem "rails", "~> 5.2.0.beta", github: "rails/rails"
gem "arel", "~> 9.0.0",  github: "rails/arel"

# Data Stores
gem "pg", "~> 0.18"
gem "chewy"

# Views
gem "haml"
gem "haml-rails"
gem "semantic-ui-sass"
gem "jquery-rails"
gem "coffee-rails" # uuuuuuugh
gem "turbolinks", "~> 5"

gem "active_link_to"
gem "kaminari"

gem "sass-rails", "~> 5.0"
gem "uglifier", ">= 1.3.0"
gem "webpacker"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem "therubyracer", platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"

# Jobs
gem "redis", "~> 3.0"
gem "hiredis"
gem "sidekiq"

# Auth
gem "omniauth-twitter"
gem "omniauth-github"

# Admin & Permissions
gem "pundit", github: "elabs/pundit"

# Request making
# gem "faraday"
# gem "faraday-encoding"
# gem "faraday_middleware"
# gem "excon"
gem "http"
gem "addressable"

# Parsing/HTML handling
# gem "nokogiri"
# gem "loofah"
# gem "ruby-readability"
# gem "stopwords-filter"
gem "robotstxt-parser", require: "robotstxt"

# Utils
gem "mustermann"

gem "connection_pool"

gem "redis-rails"
gem "redis-rack-cache"

gem "aws-sdk-s3", "~> 1"

gem "bcrypt"

# Server
gem "puma", "~> 3.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data"

group :development, :test do
  # Runner & Environment
  gem "foreman"
  gem "dotenv-rails"

  # Debugging
  gem "awesome_print"
  gem "byebug"
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "better_errors"
  gem "binding_of_caller"

  # Auto-runners for tests and docs
  gem "guard"
  gem "guard-yard"

  # Document everything
  gem "yard"

  # Handle mail intercepting in development
  gem "mailcatcher"

  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem "spring"
  # gem "spring-watcher-listen", "~> 2.0.0"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", "~> 2.13"
  gem "selenium-webdriver"

  gem "rspec"
  gem "rspec-rails", "~> 3.5"

  gem "guard-rspec"
  gem "factory_girl", "~> 4.0"
  gem "rack-test"
  gem "timecop"
  gem "webmock"
  gem "simplecov", require: false

  gem "flay"
  gem "reek"
  gem "rubocop"
  gem "rubocop-rspec"
  gem "pronto"
  gem "pronto-flay", require: false
  gem "pronto-reek", require: false
  gem "pronto-rubocop", require: false
end
