# transientBug Rails Project
This is the main server and frontend for the transientBug.ninja bookmarking
service.

[![Build Status](https://travis-ci.org/transientBug/transientbug-rails.svg?branch=master)](https://travis-ci.org/transientBug/transientbug-rails)

# Setup
General principles:
 - Try to keep it simple, mkay?

## Stack:
 - Docker for dev/deployments

### Backend:
 - Ruby on Rails 5.2
   - Ruby 2.5.1
   - Sidekiq for ActiveJob
   - Clockwork.rb for periodic tasks
 - Postgresql 9.6
 - Elasticsearch 5.6
 - Redis 4

### Frontend
 - Semantic-UI
 - JQuery for basic stuff
 - React for advanced stuff
 - Webpack 4 & Sprockets
   - Node 8 with the webpacker gem
   - Current thoughts are to ditch Sprockets, idk.

~A Paw.app file is provided and I try to keep it up to date with the current
API.~ Currently the paw file has been removed but I'm working on a better
replacement.

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
