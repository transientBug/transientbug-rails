FROM ruby:3.1.0
LABEL maintainer="Josh Ashby <me@joshisa.ninja>"
LABEL org.opencontainers.image.source = "https://github.com/transientBug/transientbug-rails"

ENV BUNDLE_SILENCE_ROOT_WARNING true
ENV AWS_SDK_CONFIG_OPT_OUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

ARG ENV
ENV RAILS_ENV ${ENV:-production}
ENV NODE_ENV ${ENV:-production}

ARG PORT
ENV PORT ${PORT:-3000}

ENV LANG=C.UTF-8
# Set this so that CTRL+G works properly
ENV TERM=xterm

ENV HOME=/app

EXPOSE 3000
VOLUME ["/dropzone"]

# Install any additional tooling we need to build/compile things
RUN apt-get update && \
    apt-get install -y curl postgresql-client imagemagick 

# Ensure node is updated to LTS
#RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    #apt-get install -y nodejs && \
    #npm i npm@latest -g

# Add a slightly less privlaged user to run under
RUN adduser --shell /bin/bash --uid 1001 --ingroup root --home "${HOME}" --system app && \
    chown -R 1001:0 "${HOME}"

WORKDIR ${HOME}
USER app

COPY --chown=app:0 Gemfile Gemfile.lock ./
RUN echo "install: --no-document" > $HOME/.gemrc && \
    echo "update: --no-document" >> $HOME/.gemrc && \
    bundle config set without 'development test' && \
    bundle install && \
    bundle exec rails tmp:create

COPY --chown=app:0 . ./

ENTRYPOINT ["/bin/bash", "docker/entrypoint.sh"]
