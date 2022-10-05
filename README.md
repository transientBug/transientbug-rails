# transientBug Rails Project
This is the main server and frontend for the transientBug.ninja bookmarking
service.

[![Build](https://github.com/transientBug/transientbug-rails/actions/workflows/build.yml/badge.svg?branch=master&event=check_suite)](https://github.com/transientBug/transientbug-rails/actions/workflows/build.yml)

# Setup
General principles:
 - Try to keep it simple, mkay?

## Stack:
 - Fly.io for deployments
  - Setup a redis server using `cd redis && fly deploy`
    - you'll need to make a password for redis `fly secrets set REDIS_PASSWORD=mypassword`
  - `fly secrets set REDIS_URL=redis://default:mypassword@hostname.fly.dev:6379/0`
  - `fly secrets set RAILS_MASTER_KEY=(cat config/master.key)`
  - `fly deploy --build-secret RAILS_MASTER_KEY=(cat config/master.key)`

### Backend:
 - Ruby on Rails 7
   - Ruby 3.1.0
   - GoodJob for ActiveJob
 - Postgresql 14+
 - Redis 6+ for cache and session stores

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
 - GitHub Actions CI runs specs, yard documentation and rubocop
