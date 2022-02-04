# transientBug Rails Project
This is the main server and frontend for the transientBug.ninja bookmarking
service.

[![Build](https://github.com/transientBug/transientbug-rails/actions/workflows/build.yml/badge.svg?branch=master&event=check_suite)](https://github.com/transientBug/transientbug-rails/actions/workflows/build.yml)

# Setup
General principles:
 - Try to keep it simple, mkay?

## Stack:
 - Docker for dev/deployments

### Backend:
 - Ruby on Rails 7
   - Ruby 3.1.0
   - Sidekiq for ActiveJob
   - Clockwork.rb for periodic tasks (not actively used)
 - Postgresql 9.6
 - Redis 4

### Frontend
 - TailwindCSS
 - Stimulus & Turbo via rollup

# Testing
Chrome headless is being setup for the capybara tests, you should install it
with something like
```
brew install chromedriver
```
Or look into using a [helper](https://github.com/flavorjones/chromedriver-helper).

Basics:
 - RSpec is used for tests (eventually, they're a work in progress) deal with it
 - Capybara specs run with chrome-headless
 - Travis CI runs specs, yard documentation and rubocop
