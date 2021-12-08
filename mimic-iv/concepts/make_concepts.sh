#!/bin/bash
# This script generates the concepts in the BigQuery table mimic_derived.
export TARGET_DATASET=mimic_derived

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

            # skip first_day_sofa as it depends on other firstday queries
            if [[ "${tbl}" == "first_day_sofa" ]]; then
                continue
            # kdigo_stages needs to be run after creat/uo
            elif [[ "${tbl}" == "kdigo_stages" ]]; then
                continue
            # vasoactive tables also need to be run last
            elif [[ "${tbl}" == "vasoactive_agent" ]]; then
                continue
            elif [[ "${tbl}" == "norepinephrine_equivalent_dose" ]]; then
                continue
            fi
            echo "Generating ${TARGET_DATASET}.${tbl}"
            bq query --use_legacy_sql=False --replace --destination_table=${TARGET_DATASET}.${tbl} < ${d}/${fn}
        fi
    done
done

# generate first_day_sofa table last
echo "Generating ${TARGET_DATASET}.first_day_sofa"
bq query --use_legacy_sql=False --replace --destination_table=${TARGET_DATASET}.first_day_sofa < firstday/first_day_sofa.sql

# generate first_day_sofa table last
echo "Generating ${TARGET_DATASET}.kdigo_stages"
bq query --use_legacy_sql=False --replace --destination_table=${TARGET_DATASET}.kdigo_stages < organfailure/kdigo_stages.sql

# generate vasoactive tables - first agent table, then NED table
echo "Generating ${TARGET_DATASET}.vasoactive_agent"
bq query --use_legacy_sql=False --replace --destination_table=${TARGET_DATASET}.vasoactive_agent < medication/vasoactive_agent.sql
echo "Generating ${TARGET_DATASET}.norepinephrine_equivalent_dose"
bq query --use_legacy_sql=False --replace --destination_table=${TARGET_DATASET}.norepinephrine_equivalent_dose < medication/norepinephrine_equivalent_dose.sql