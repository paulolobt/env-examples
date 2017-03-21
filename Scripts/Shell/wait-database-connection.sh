#!/bin/bash

set -e

database_host="$1"
shift
post_command="$@"

# Wait database connection
until curl "http://$database_host/" &>/dev/null; do
  >&2 echo "Database is unavailable - still trying"
  sleep 3
done

>&2 echo "Database is up - executing command"
exec $post_command

