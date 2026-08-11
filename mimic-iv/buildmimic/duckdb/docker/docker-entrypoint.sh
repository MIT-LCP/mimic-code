#!/bin/sh
# This entrypoint exists as we need to infer the user ID from the bind mount to
# re-assign ownership of the output db file from root to the user.
set -eu

give_output_to_host_user() {
    chown -R --reference=/out /out 2>/dev/null || true
}
trap give_output_to_host_user EXIT

/mimic/buildmimic/duckdb/build_mimic.sh "$@"
