#!/bin/bash
# This script copies the concepts in the BigQuery table mimiciv_derived to mimiciv_${VERSION}_derived.
if [ -z "$$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi
export SOURCE_DATASET=mimiciv_derived
export TARGET_DATASET=mimiciv_$1_derived

# check if the target dataset exists
if bq ls | grep -q ${TARGET_DATASET}; then
    echo "Using existing dataset ${TARGET_DATASET}."
    # drop the existing tables in the target dataset
    # this includes ones which may not be in the source dataset
    for TABLE in `bq ls physionet-data:${TARGET_DATASET} | cut -d' ' -f3`;
    do
        # skip the first line of dashes
        if [[ "${TABLE:0:2}" == '--' ]]; then
            continue
        fi
        echo "Dropping table ${TARGET_DATASET}.${TABLE}"
        bq rm -f -q ${TARGET_DATASET}.${TABLE}
    done
else
    echo "Creating dataset ${TARGET_DATASET}"
    bq mk --dataset ${TARGET_DATASET}
fi

for TABLE in `bq ls physionet-data:${SOURCE_DATASET} | cut -d' ' -f3`;
do
    # skip the first line of dashes
    if [[ "${TABLE:0:2}" == '--' ]]; then
      continue
    fi
    echo "${SOURCE_DATASET}.${TABLE} -> ${TARGET_DATASET}.${TABLE}"
    bq cp -f -q ${SOURCE_DATASET}.${TABLE} ${TARGET_DATASET}.${TABLE}
done
