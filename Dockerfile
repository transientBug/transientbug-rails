FROM ruby:2.4-alpine3.6
LABEL maintainer="Josh Ashby <me@joshisa.ninja>"

ENV LANG en_US.utf8

RUN apk add --no-cache --update build-base postgresql postgresql-dev sqlite-dev cmake git curl

RUN echo -e 'http://dl-cdn.alpinelinux.org/alpine/edge/main\nhttp://dl-cdn.alpinelinux.org/alpine/edge/community\nhttp://dl-cdn.alpinelinux.org/alpine/edge/testing' > /etc/apk/repositories && \
    apk add --no-cache nodejs-current yarn

RUN mkdir /app
RUN mkdir /dropzone
WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN echo "install: --no-document" > $HOME/.gemrc && echo "update: --no-document" >> $HOME/.gemrc
RUN bundle install --binstubs --jobs 4

COPY . ./

ENV PGDATA /var/lib/postgresql/data

RUN su postgres -c 'pg_ctl -w initdb' &&\
    su postgres -c 'pg_ctl -w start' &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker docker &&\
    bundle exec rake RAILS_ENV=production DATABASE_URL=postgresql://docker:docker@127.0.0.1/docker assets:precompile docs:generate

VOLUME ["/app/public", "/dropzone"]

CMD bundle exec puma -C config/puma.rb
