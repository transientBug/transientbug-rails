FROM ruby:2.6.3-alpine
LABEL maintainer="Josh Ashby <me@joshisa.ninja>"

RUN echo -e 'http://dl-cdn.alpinelinux.org/alpine/edge/main\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing' > /etc/apk/repositories && \
    apk add --no-cache build-base gcompat git curl postgresql-dev postgresql nodejs-current yarn && \
    echo "install: --no-document" > $HOME/.gemrc && \
    echo "update: --no-document" >> $HOME/.gemrc && \
    mkdir /dropzone && \
    mkdir /app

WORKDIR /app

VOLUME ["/app/public", "/dropzone"]

COPY Gemfile Gemfile.lock ./
RUN  bundle install --binstubs --jobs 4 --without development test && \
     bundle exec rake tmp:create

COPY . .

CMD bundle exec puma -C config/puma.rb
