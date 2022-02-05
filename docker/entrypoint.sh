#!/usr/bin/env bash
set -euo pipefail

# if a command was passed to this script, run it in the environment
if [[ $# -gt 0 ]]; then
  echo "Running command $@"
  exec bash -c "$@"
fi

echo "Running migrations ..."
bundle exec rails db:migrate

echo "Starting server ..."
exec bundle exec puma -C config/puma.rb
