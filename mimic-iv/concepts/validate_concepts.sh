#!/bin/bash
# Validates the derived concepts built in a BigQuery dataset by checking:
#   1. every concept SQL file has a corresponding table in the dataset
#   2. no concept table is empty
#
# Usage: validate_concepts.sh [dataset]
#   dataset defaults to mimiciv_derived
set -euo pipefail

PROJECT_ID=${PROJECT_ID:-physionet-data}
DATASET=${1:-mimiciv_derived}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EXPECTED="$(
  for d in demographics comorbidity measurement medication organfailure treatment firstday score sepsis; do
    for fn in "${SCRIPT_DIR}/${d}"/*.sql; do
      basename "${fn}" .sql
    done
  done | sort -u
)"

echo "Fetching table metadata for ${PROJECT_ID}:${DATASET}"
# row_count is read straight from table metadata; this does not scan the tables.
ACTUAL="$(bq query --quiet --headless --use_legacy_sql=false --format=csv \
  "SELECT table_id, row_count FROM \`${PROJECT_ID}.${DATASET}.__TABLES__\`" \
  | tail -n +2)"

fail=0

# Check 1: every expected table is present.
missing=0
while read -r tbl; do
  [ -z "${tbl}" ] && continue
  if ! grep -q "^${tbl}," <<< "${ACTUAL}"; then
    echo "MISSING: expected table ${DATASET}.${tbl} was not built"
    missing=1
    fail=1
  fi
done <<< "${EXPECTED}"
if [ "${missing}" -eq 0 ]; then
  echo "OK: all $(grep -c . <<< "${EXPECTED}") expected tables are present"
fi

# Check 2: no expected table is empty.
empty=0
while IFS=, read -r tbl rows; do
  [ -z "${tbl}" ] && continue
  # only validate the tables we actually build (ignore _metadata and any strays)
  if grep -qx "${tbl}" <<< "${EXPECTED}" && [ "${rows}" -eq 0 ]; then
    echo "EMPTY: table ${DATASET}.${tbl} has 0 rows"
    empty=1
    fail=1
  fi
done <<< "${ACTUAL}"
if [ "${empty}" -eq 0 ]; then
  echo "OK: no concept table is empty"
fi

if [ "${fail}" -ne 0 ]; then
  echo "Validation FAILED for ${PROJECT_ID}:${DATASET}"
  exit 1
fi
echo "Validation passed for ${PROJECT_ID}:${DATASET}"
