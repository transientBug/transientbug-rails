FROM ruby:2.6.3-buster

LABEL maintainer="Josh Ashby <ashby@transientbug.ninja>"

RUN gem install rubocop rubocop-rails rubocop-rspec

COPY cop.rb cop.rb
ENTRYPOINT ["ruby", "/cop.rb"]
