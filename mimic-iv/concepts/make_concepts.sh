#!/bin/bash
# This script generates the concepts in the BigQuery table mimic_derived.
export TARGET_DATASET=mimic_derived

# specify bigquery query command options
# note: max_rows=1 *displays* only one row, but all rows are inserted into the destination table
BQ_OPTIONS='--quiet --headless --max_rows=1 --use_legacy_sql=False --replace'

# generate tables in subfolders
# order is important for a few tables here:
# * firstday should go last
# * sepsis depends on score (sofa.sql in particular)
# * organfailure depends on measurement
for d in comorbidity demographics measurement medication organfailure treatment score sepsis firstday;
do
    for fn in `ls $d`;
    do
        # only run SQL queries
        if [[ "${fn: -4}" == ".sql" ]]; then
            # table name is file name minus extension
            tbl=`echo $fn | rev | cut -d. -f2- | rev`

            # skip certain tables where order matters - generated at the end of the script
            skip=0
            for skip_table in first_day_sofa kdigo_stages vasoactive_agent norepinephrine_eqivalent_dose
            do
              if [[ "${tbl}" == "${skip_table}" ]]; then
                skip=1
                break
              fi
            done;
            if [[ "${skip}" == "1" ]]; then
              continue
            fi

            # not skipping - so generate the table on bigquery
            echo "Generating ${TARGET_DATASET}.${tbl}"
            bq query "${BQ_OPTIONS}" --destination_table=${TARGET_DATASET}.${tbl} < ${d}/${fn}
        fi
    done
done

echo "Now generating tables which were skipped due to depending on other tables."
# generate tables after the above, and in a specific order to ensure dependencies are met
for table_path in firstday/first_day_sofa organfailure/kdigo_stages medication/vasoactive_agent medication/norepinephrine_equivalent_dose;
do
  table=`echo $table_path | rev | cut -d/ -f1 | rev`

  echo "Generating ${TARGET_DATASET}.${table}"
  bq query "${BQ_OPTIONS}" --destination_table=${TARGET_DATASET}.${table} < ${table_path}.sql
done