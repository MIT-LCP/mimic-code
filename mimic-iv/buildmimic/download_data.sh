#!/bin/bash
# Download MIMIC-IV from PhysioNet into a directory any of the builds can use.
#
# Usage: ./download_data.sh [destination] [physionet-username]
#
#   destination           where to put the data (default ./mimic-data)
#   physionet-username    also read from $PHYSIONET_USER, otherwise prompted for
#
# Requires a PhysioNet account credentialed for MIMIC-IV. The password is always
# requested interactively, so it never reaches the process list or shell history.
#
# Shared by the postgres and duckdb builds: both want the same hosp/ and icu/
# layout, so there is one copy of this here rather than one per engine.
#
# This is a convenience only. If you already have the data, point MIMIC_DATA_DIR
# at it instead; any directory with hosp/ and icu/ subfolders will do.
set -euo pipefail

# The build scripts target the current release of MIMIC-IV.
readonly MIMIC_VERSION="3.1"

DEST="${1:-./mimic-data}"
USERNAME="${2:-${PHYSIONET_USER:-}}"

if [ -z "${USERNAME}" ]; then
    read -rp "PhysioNet username: " USERNAME
fi

echo "Downloading MIMIC-IV v${MIMIC_VERSION} to ${DEST}"

# -nH --cut-dirs=4 strips physionet.org/files/mimiciv/<version>/ from the paths,
# leaving the hosp/ and icu/ subfolders directly under ${DEST}. That is the
# layout buildmimic/postgres/load_gz.sql expects.
wget -r -N -c -np -nH --cut-dirs=4 \
    -A '*.csv.gz' \
    -P "${DEST}" \
    --user "${USERNAME}" --ask-password \
    "https://physionet.org/files/mimiciv/${MIMIC_VERSION}/"

echo "Downloaded $(find "${DEST}" -name '*.csv.gz' | wc -l | tr -d ' ') files to ${DEST}"
