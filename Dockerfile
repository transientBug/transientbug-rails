FROM ruby:2.6.3-alpine
LABEL maintainer="Josh Ashby <me@joshisa.ninja>"

RUN apk add --no-cache --update build-base postgresql-dev postgresql git curl

RUN echo -e 'http://dl-cdn.alpinelinux.org/alpine/edge/main\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing' > /etc/apk/repositories && \
    apk add --no-cache nodejs-current yarn

RUN mkdir /app
RUN mkdir /dropzone
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN echo "install: --no-document" > $HOME/.gemrc && echo "update: --no-document" >> $HOME/.gemrc
RUN bundle install --binstubs --jobs 4 --without development test

COPY . .

VOLUME ["/app/public", "/dropzone"]

CMD bundle exec puma -C config/puma.rb
