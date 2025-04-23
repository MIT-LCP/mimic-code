#!/bin/bash
# This script copies the concepts in the BigQuery table mimiciv_derived to mimiciv_${VERSION}_derived.
if [ -z "$$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi
export SOURCE_DATASET=mimiciv_derived
export TARGET_DATASET=mimiciv_$1_derived
export PROJECT_ID=physionet-data

# check if the target dataset exists
if bq ls --datasets --project_id ${PROJECT_ID} | grep -q ${TARGET_DATASET}; then
    echo "Using existing dataset ${TARGET_DATASET}."
    # drop the existing tables in the target dataset
    # this includes ones which may not be in the source dataset
    for TABLE in `bq ls ${PROJECT_ID}:${TARGET_DATASET} | cut -d' ' -f3`;
    do
        # skip the first line of dashes
        if [[ "${TABLE:0:2}" == '--' ]]; then
            continue
        fi
        bq rm -f -q ${PROJECT_ID}:${TARGET_DATASET}.${TABLE}
    done
else
    echo "Creating dataset ${PROJECT_ID}:${TARGET_DATASET}"
    bq mk --dataset ${PROJECT_ID}:${TARGET_DATASET}
fi

echo "Copying tables from ${SOURCE_DATASET} to ${TARGET_DATASET}."
for TABLE in `bq ls ${PROJECT_ID}:${SOURCE_DATASET} | cut -d' ' -f3`;
do
    # skip the first line of dashes
    if [[ "${TABLE:0:2}" == '--' ]]; then
      continue
    fi
    bq cp -f -q ${PROJECT_ID}:${SOURCE_DATASET}.${TABLE} ${PROJECT_ID}:${TARGET_DATASET}.${TABLE}
done
