#!/bin/sh
set -e

# check/install gem dependencies with 4 parallel jobs
bundle check || bundle install -j4

# Remove a potentially pre-existing server.pid for Rails.
if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
