FROM ruby:3.0.1-alpine
LABEL maintainer="Josh Ashby <me@joshisa.ninja>"

WORKDIR /app
VOLUME ["/dropzone"]

#RUN echo -e 'http://dl-cdn.alpinelinux.org/alpine/edge/main\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing' > /etc/apk/repositories && \
RUN apk add --no-cache bash build-base gcompat git curl postgresql-dev postgresql nodejs-current yarn && \
    echo "install: --no-document" > $HOME/.gemrc && \
    echo "update: --no-document" >> $HOME/.gemrc

COPY . .
RUN bundle config set without 'development test' && \
    bundle install --jobs 4 && \
    bundle exec rake tmp:create

ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
