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
 - Ruby on Rails 6.1
   - Ruby 3.0.1
   - Sidekiq for ActiveJob
   - Clockwork.rb for periodic tasks (ot actively used)
 - Postgresql 9.6
 - Redis 4

### Frontend
 - Semantic-UI
 - JQuery for basic stuff
 - React for advanced stuff
 - Webpack 4 & Sprockets
   - Node 16 with the webpacker gem
   - Current thoughts are to ditch Sprockets, idk.

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
