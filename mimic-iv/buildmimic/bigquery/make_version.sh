#!/bin/bash
# This script makes the _version table for each schema in BigQuery,
# Currently hard-coded to the status as of 2025-04-20.
export METADATA_TABLE="_metadata"

# create an array of target datasets and versions
# loop through them at the same time
datasets=(
  "mimiciv_icu:3.1"
  "mimiciv_hosp:3.1"
  "mimiciv_note:2.2"
  "mimiciv_ed:2.2"
)

for entry in "${datasets[@]}"; do
  TARGET_DATASET="${entry%%:*}"
  MIMIC_VERSION="${entry##*:}"
  export TARGET_DATASET
  export MIMIC_VERSION
  
  echo "Creating ${TARGET_DATASET}.${METADATA_TABLE} table"
    bq query <<EOF
CREATE TABLE IF NOT EXISTS \`physionet-data.${TARGET_DATASET}.${METADATA_TABLE}\` (
  attribute STRING,
  value STRING
);

TRUNCATE TABLE \`physionet-data.${TARGET_DATASET}.${METADATA_TABLE}\`;

INSERT INTO \`physionet-data.${TARGET_DATASET}.${METADATA_TABLE}\` (attribute, value)
VALUES
  ('mimic_version', '${MIMIC_VERSION}');
EOF
done