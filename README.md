# transientBug Rails Project
This is the main server and frontend for the transientBug.ninja website.

# Setup
General principles:
 - Try to keep it simple, mkay?

Stack:
 - Ruby on Rails 5.2
   - Ruby 2.4.1 (aim is to upgrade to 2.5 soonish)
   - Node 8 for webpacker gem
   - Sidekiq for ActiveJob
   - Clockwork.rb for periodic tasks
   - Docker for dev/deployments
 - Postgresql 9.6
 - Elasticsearch 5.6
 - Redis 4

A Paw.app file is provided and I try to keep it up to date with the current
API.

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
