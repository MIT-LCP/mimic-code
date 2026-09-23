#!/bin/bash
# postgres_env.sh: Set PostgreSQL environment variables for your session
# Usage: source postgres_env.sh [user] [password] [database] [host] [port]
# You can override the defaults by passing arguments as shown above.

export PGUSER="${1:-your_user}"
export PGPASSWORD="${2:-your_password}"
export PGDATABASE="${3:-nw}"
export PGHOST="${4:-localhost}"
export PGPORT="${5:-5432}"

echo "PostgreSQL environment variables set:"
echo "  PGUSER=$PGUSER"
echo "  PGPASSWORD=********"
echo "  PGDATABASE=$PGDATABASE"
echo "  PGHOST=$PGHOST"
echo "  PGPORT=$PGPORT"
