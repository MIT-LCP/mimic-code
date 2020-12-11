#!/bin/bash
# This script generates the concepts in the BigQuery table mimic_derived.
export TARGET_DATASET=mimic_derived

# generate tables in subfolders
for d in demographics measurement medication treatment firstday score;
do
    for fn in `ls $d`;
    do
        # only run SQL queries
        if [[ "${fn: -4}" == ".sql" ]]; then
            # table name is file name minus extension
            tbl="${fn::-4}"

            echo "Generating ${TARGET_DATASET}.${tbl}"
            bq query --use_legacy_sql=False --replace --destination_table=${TARGET_DATASET}.${tbl} < ${d}/${fn}
        fi
    done
done

