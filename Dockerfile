FROM ruby:3.1.0-alpine
LABEL maintainer="Josh Ashby <me@joshisa.ninja>"
LABEL org.opencontainers.image.source = "https://github.com/transientBug/transientbug-rails"

WORKDIR /app
VOLUME ["/dropzone"]

#RUN echo -e 'http://dl-cdn.alpinelinux.org/alpine/edge/main\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing' > /etc/apk/repositories && \
RUN apk add --no-cache bash build-base gcompat git curl postgresql-dev postgresql nodejs-current yarn && \
    echo "install: --no-document" > $HOME/.gemrc && \
    echo "update: --no-document" >> $HOME/.gemrc

RUN gem update bundler

COPY . .
RUN bundle config set without 'development test' && \
    bundle install && \
    bundle exec rails tmp:create

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
