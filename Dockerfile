FROM ruby:2.4-alpine
LABEL maintainer="Josh Ashby <me@joshisa.ninja>"

RUN apk add --no-cache --update build-base postgresql-dev git curl

RUN echo -e 'http://dl-cdn.alpinelinux.org/alpine/edge/main\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing' > /etc/apk/repositories
RUN apk add --no-cache nodejs-current yarn

RUN mkdir /app
WORKDIR /app

RUN echo "install: --no-document" > $HOME/.gemrc && echo "update: --no-document" >> $HOME/.gemrc
COPY Gemfile Gemfile.lock ./
RUN bundle install --binstubs --without development test --jobs 4

COPY . .

RUN bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname SECRET_TOKEN=pickasecuretoken assets:precompile

VOLUME ["/app/public"]

CMD puma -C config/puma.rb
