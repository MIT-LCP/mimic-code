#!/bin/bash
# This shell script converts BigQuery .sql files into PostgreSQL .sql files.

# path in which we create the postgres concepts
TARGET_PATH='../concepts_postgres'
mkdir -p $TARGET_PATH

# String replacements are necessary for some queries.
export REGEX_SCHEMA='s/`physionet-data.(mimiciv_hosp|mimiciv_icu|mimiciv_derived).([A-Za-z0-9_-]+)`/\1.\2/g'
# Note that these queries are very senstive to changes, e.g. adding whitespaces after comma can already change the behavior.
export REGEX_DATETIME_DIFF="s/DATETIME_DIFF\(([^,]+), ?(.*), ?(DAY|MINUTE|SECOND|HOUR|YEAR)\)/DATETIME_DIFF(\1, \2, '\3')/g"
export REGEX_DATETIME_TRUNC="s/DATETIME_TRUNC\(([^,]+), ?(DAY|MINUTE|SECOND|HOUR|YEAR)\)/DATE_TRUNC('\2', \1)/g"
# Add necessary quotes to INTERVAL, e.g. "INTERVAL 5 hour" to "INTERVAL '5' hour"
export REGEX_INTERVAL="s/interval ([[:digit:]]+) (hour|day|month|year)/INTERVAL '\1' \2/gI"
# Specific queries for some problems that arose with some files.
export REGEX_INT="s/CAST\(hr AS INT64\)/CAST\(hr AS bigint\)/g"
export REGEX_ARRAY="s/GENERATE_ARRAY\(-24, CEIL\(DATETIME\_DIFF\(it\.outtime_hr, it\.intime_hr, HOUR\)\)\)/ARRAY\(SELECT \* FROM generate\_series\(-24, CEIL\(DATETIME\_DIFF\(it\.outtime_hr, it\.intime_hr, HOUR\)\)\)\)/g"
export REGEX_HOUR_INTERVAL="s/INTERVAL CAST\(hr AS INT64\) HOUR/interval \'1\' hour * CAST\(hr AS bigint\)/g"
export REGEX_SECONDS="s/SECOND\)/\'SECOND\'\)/g"
export CONNSTR='-U postgres -h localhost -p 5500 -d mimic-iv'  # -d mimic


# First, we re-create the postgres-make-concepts.sql file.
echo "\echo ''" > $TARGET_PATH/postgres-make-concepts.sql

# Now we add some preamble for the user running the script.
echo "\echo '==='" >> $TARGET_PATH/postgres-make-concepts.sql
echo "\echo 'Beginning to create materialized views for MIMIC database.'" >> $TARGET_PATH/postgres-make-concepts.sql
echo "\echo '"'Any notices of the form  "NOTICE: materialized view "XXXXXX" does not exist" can be ignored.'"'" >> $TARGET_PATH/postgres-make-concepts.sql
echo "\echo 'The scripts drop views before creating them, and these notices indicate nothing existed prior to creating the view.'" >> $TARGET_PATH/postgres-make-concepts.sql
echo "\echo '==='" >> $TARGET_PATH/postgres-make-concepts.sql
echo "\echo ''" >> $TARGET_PATH/postgres-make-concepts.sql

# reporting to stdout the folder being run
echo -n "Dependencies:"

# output table creation calls to the make-concepts script
echo "" >> $TARGET_PATH/postgres-make-concepts.sql
echo "-- dependencies" >> $TARGET_PATH/postgres-make-concepts.sql

for dir_and_table in demographics.icustay_times demographics.weight_durations measurement.urine_output organfailure.kdigo_uo;
do
  d=`echo ${dir_and_table} | cut -d. -f1`
  tbl=`echo ${dir_and_table} | cut -d. -f2`

  # make the sub-folder for postgres if it does not exist
  mkdir -p "$TARGET_PATH/${d}"
  
  # convert the bigquery script to psql and output it to the appropriate subfolder
  echo -n " ${d}.${tbl} .."
  echo "-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY." > "$TARGET_PATH/${d}/${tbl}.sql"
  echo "DROP TABLE IF EXISTS ${tbl}; CREATE TABLE ${tbl} AS " >> "$TARGET_PATH/${d}/${tbl}.sql"

  # for two scripts, add a perl replace to cast rounded values as numeric
  if [[ "${tbl}" == "icustay_times" ]] || [[ "${tbl}" == "urine_output" ]]; then
    cat "${d}/${tbl}.sql" | sed -r -e "${REGEX_ARRAY}" | sed -r -e "${REGEX_HOUR_INTERVAL}" | sed -r -e "${REGEX_INT}" | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_DATETIME_TRUNC}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | sed -r -e "${REGEX_SECONDS}" >> "$TARGET_PATH/${d}/${tbl}.sql"
  else
    cat "${d}/${tbl}.sql" | sed -r -e "${REGEX_ARRAY}" | sed -r -e "${REGEX_HOUR_INTERVAL}" | sed -r -e "${REGEX_INT}" | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_DATETIME_TRUNC}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | sed -r -e "${REGEX_SECONDS}" >> "$TARGET_PATH/${d}/${tbl}.sql"
  fi

  # write out a call to this script in the make concepts file
  echo "\i ${d}/${tbl}.sql" >> $TARGET_PATH/postgres-make-concepts.sql
done
echo " done!"

# Iterate through each concept subfolder, and:
# (1) apply the above regular expressions to update the script
# (2) output to the postgres subfolder
# (3) add a line to the postgres-make-concepts.sql script to generate this table

# we control the order by skipping tables listed in the below var
DIR_AND_TABLES_TO_SKIP='demographics.icustay_times demographics.weight_durations measurement.urine_output organfailure.kdigo_uo organfailure.kdigo_stages firstday.first_day_sofa sepsis.sepsis3 medication.vasoactive_agent medication.norepinephrine_equivalent_dose'

# create an array to store tables for which the order of generation matters
# i.e. these tables cannot be generated in alphabetical order, as done in the later loop
TABLES_TO_SKIP=()
for dir_and_table in $DIR_AND_TABLES_TO_SKIP;
do
  tbl=`echo ${dir_and_table} | cut -d. -f2`
  TABLES_TO_SKIP+=($tbl)
done

echo $TABLES_TO_SKIP
# the order *only* matters during the conversion step because our loop is
# inserting table build commands into the postgres-make-concepts.sql file
for d in demographics measurement comorbidity medication treatment firstday organfailure score sepsis;
do
    mkdir -p "$TARGET_PATH/${d}"
    echo -n "${d}:"
    echo "" >> $TARGET_PATH/postgres-make-concepts.sql
    echo "-- ${d}" >> $TARGET_PATH/postgres-make-concepts.sql
    for fn in `ls $d`;
    do
        # only run SQL queries
        if [[ "${fn: -4}" == ".sql" ]]; then
            # table name is file name minus extension
            tbl="${fn%????}"

            # skip first_day_sofa as it depends on other firstday queries, we'll generate it later
            # we also skipped tables generated in the "Dependencies" loop above.
            if [[ "${tbl}" == "first_day_sofa" ]] || [[ "${tbl}" == "icustay_times" ]] || [[ "${tbl}" == "weight_durations" ]] || [[ "${tbl}" == "urine_output" ]] || [[ "${tbl}" == "kdigo_uo" ]] || [[ "${tbl}" == "sepsis3" ]]; then
                continue
            fi
            echo -n " ${tbl} .."
            echo "-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY." > "postgres/${d}/${tbl}.sql"
            echo "DROP TABLE IF EXISTS ${tbl}; CREATE TABLE ${tbl} AS " >> "postgres/${d}/${tbl}.sql"
            cat "${d}/${tbl}.sql" | sed -r -e "${REGEX_ARRAY}" | sed -r -e "${REGEX_HOUR_INTERVAL}" | sed -r -e "${REGEX_INT}" | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_DATETIME_TRUNC}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" >> "${TARGET_PATH}/${d}/${fn}"

            if [[ ! " ${TABLES_TO_SKIP[*]} " =~ " ${tbl} " ]]; then
                # this table is *not* in our skip array
                # therefore, we print it out to the make concepts script
                echo "\i ${d}/${fn}" >> postgres/postgres-make-concepts.sql
            fi
        fi
    done
    echo " done!"
done

# finally generate first_day_sofa which depends on concepts in firstday folder
echo "" >> postgres/postgres-make-concepts.sql
echo "-- final tables which were dependent on one or more prior tables" >> ${TARGET_PATH}/postgres-make-concepts.sql

echo -n "final:"
for dir_and_table in $DIR_AND_TABLES_TO_SKIP
do
  d=`echo ${dir_and_table} | cut -d. -f1`
  tbl=`echo ${dir_and_table} | cut -d. -f2`

  # make the sub-folder for postgres if it does not exist
  mkdir -p "$TARGET_PATH/${d}"
  
  # convert the bigquery script to psql and output it to the appropriate subfolder
  echo -n " ${d}.${tbl} .."
  echo "-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY." > "$TARGET_PATH/${d}/${tbl}.sql"
  echo "DROP TABLE IF EXISTS ${tbl}; CREATE TABLE ${tbl} AS " >> "$TARGET_PATH/${d}/${tbl}.sql"

  cat "${d}/${tbl}.sql" | sed -r -e "${REGEX_ARRAY}" | sed -r -e "${REGEX_HOUR_INTERVAL}" | sed -r -e "${REGEX_INT}" | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_DATETIME_TRUNC}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | sed -r -e "${REGEX_SECONDS}" >> "$TARGET_PATH/${d}/${tbl}.sql"

  # write out a call to this script in the make concepts file
  echo "\i ${d}/${tbl}.sql" >> $TARGET_PATH/postgres-make-concepts.sql
done
echo " done!"
