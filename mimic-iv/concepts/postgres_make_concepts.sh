#!/bin/bash
# This file makes tables for the concepts in this subfolder.
# Be sure to run postgres-functions.sql first, as the concepts rely on those function definitions.
# Note that this may take a large amount of time and hard drive space.

# String replacements are necessary for some queries.
export REGEX_SCHEMA='s/`physionet-data.(mimic_core|mimic_icu|mimic_derived|mimic_hosp).(.+?)`/\1.\2/g'
# Note that these queries are very senstive to changes, e.g. adding whitespaces after comma can already change the behavior.
export REGEX_DATETIME_DIFF="s/DATETIME_DIFF\((.+?),\s?(.+?),\s?(DAY|MINUTE|SECOND|HOUR|YEAR)\)/DATETIME_DIFF(\1,\2,'\3')/g"
# Add necessary quotes to INTERVAL, e.g. "INTERVAL 5 hour" to "INTERVAL '5' hour"
export REGEX_INTERVAL="s/interval\s([[:digit:]]+)\s(hour|day|month|year)/INTERVAL '\1' \2/gI"
# Add numeric cast to ROUND(), e.g. "ROUND(1.234, 2)" to "ROUND( CAST(1.234 as numeric), 2)".
export PERL_REGEX_ROUND='s/ROUND\(((.|\n)*?)\, /ROUND\( CAST\( \1 as numeric\)\,/g'
# Specific queries for some problems that arose with some files.
export REGEX_INT="s/CAST\(hr AS INT64\)/CAST\(hr AS bigint\)/g"
export REGEX_ARRAY="s/GENERATE_ARRAY\(-24, CEIL\(DATETIME\_DIFF\(it\.outtime_hr, it\.intime_hr, HOUR\)\)\)/ARRAY\(SELECT \* FROM generate\_series\(-24, CEIL\(DATETIME\_DIFF\(it\.outtime_hr, it\.intime_hr, HOUR\)\)\)\)/g"
export REGEX_HOUR_INTERVAL="s/INTERVAL CAST\(hr AS INT64\) HOUR/interval \'1\' hour * CAST\(hr AS bigint\)/g"
export CONNSTR='-U postgres -h localhost -p 5500 -d mimic-iv'  # -d mimic

# This is set as the search_path variable for psql.
# A search path of "public,mimic_icu" will search both public and mimic_icu
# schemas for data, but will create tables on the public schema.
export PSQL_PREAMBLE='SET search_path TO public,mimic_icu'
export TARGET_DATASET='mimic_derived'

echo ''
echo '==='
echo 'Beginning to create tables for MIMIC database.'
echo 'Any notices of the form "NOTICE: TABLE "XXXXXX" does not exist" can be ignored.'
echo 'The scripts drop views before creating them, and these notices indicate nothing existed prior to creating the view.'
echo '==='
echo ''
echo "Generating ${TARGET_DATASET}.icustay_times"
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ${TARGET_DATASET}.icustay_times; CREATE TABLE ${TARGET_DATASET}.icustay_times AS "; cat demographics/icustay_times.sql;} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | perl -0777 -pe "${PERL_REGEX_ROUND}" |  psql ${CONNSTR}

echo "Generating ${TARGET_DATASET}.weight_durations"
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ${TARGET_DATASET}.weight_durations; CREATE TABLE ${TARGET_DATASET}.weight_durations AS "; cat demographics/weight_durations.sql;} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | psql ${CONNSTR}

echo "Generating ${TARGET_DATASET}.urine_output"
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ${TARGET_DATASET}.urine_output; CREATE TABLE ${TARGET_DATASET}.urine_output AS "; cat measurement/urine_output.sql;} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | perl -0777 -pe "${PERL_REGEX_ROUND}" |  psql ${CONNSTR}

# Explicit Regex for cast of second to 'second' in organfailure/kdigo_uo.
export REGEX_SECONDS="s/SECOND\)/\'SECOND\'\)/g"
echo "Generating ${TARGET_DATASET}.kdigo_uo"
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ${TARGET_DATASET}.kdigo_uo; CREATE TABLE ${TARGET_DATASET}.kdigo_uo AS "; cat organfailure/kdigo_uo.sql;} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | sed -r -e "${REGEX_SECONDS}" | psql ${CONNSTR}


# generate tables in subfolders
# order is important for a few tables here:
# * firstday should go last
# * sepsis depends on score (sofa.sql in particular)
# * organfailure depends on measurement
# * repeated score and sepsis at the end because some table interdepend on each other
for d in demographics measurement comorbidity medication organfailure treatment score sepsis firstday score sepsis;
do
    for fn in `ls $d`;
    do
        echo "${d}"
        # only run SQL queries
        if [[ "${fn: -4}" == ".sql" ]]; then
            # table name is file name minus extension
            tbl="${fn::-4}"

            # Create first_day_lab after measurements done and before it is used by scores.
            if [[ "${tbl}" == "charlson" ]]; then
                # Generate some tables first to prevent conflicts during processing.
                # Have to replace column names. Probalby a mistake in the original SQL script.
                export REGEX_LAB_1="s/abs_basophils/basophils_abs/g"
                export REGEX_LAB_2="s/abs_eosinophils/eosinophils_abs/g"
                export REGEX_LAB_3="s/abs_lymphocytes/lymphocytes_abs/g"
                export REGEX_LAB_4="s/abs_monocytes/monocytes_abs/g"
                export REGEX_LAB_5="s/abs_neutrophils/neutrophils_abs/g"
                export REGEX_LAB_6="s/atyps/atypical_lymphocytes/g"
                export REGEX_LAB_7="s/imm_granulocytes/immature_granulocytes/g"
                export REGEX_LAB_8="s/metas/metamyelocytes/g"
                echo "Generating ${TARGET_DATASET}.first_day_lab"
                { echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ${TARGET_DATASET}.first_day_lab; CREATE TABLE ${TARGET_DATASET}.first_day_lab AS "; cat firstday/first_day_lab.sql;} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | sed -r -e "${REGEX_LAB_1}" | sed -r -e "${REGEX_LAB_2}" | sed -r -e "${REGEX_LAB_3}" | sed -r -e "${REGEX_LAB_4}" | sed -r -e "${REGEX_LAB_5}" | sed -r -e "${REGEX_LAB_6}" | sed -r -e "${REGEX_LAB_7}" | sed -r -e "${REGEX_LAB_8}" | perl -0777 -pe "${PERL_REGEX_ROUND}" |  psql ${CONNSTR}
            fi

            # skip first_day_sofa as it depends on other firstday queries, also skipped already processed tables.
            if [[ "${tbl}" == "first_day_sofa" ]] || [[ "${tbl}" == "icustay_times" ]] || [[ "${tbl}" == "weight_durations" ]] || [[ "${tbl}" == "urine_output" ]] || [[ "${tbl}" == "kdigo_uo" ]] || [[ "${tbl}" == "first_day_lab" ]]; then
                continue
            fi
            echo "Generating ${TARGET_DATASET}.${tbl}"
            { echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ${TARGET_DATASET}.${tbl}; CREATE TABLE ${TARGET_DATASET}.${tbl} AS "; cat "${d}/${fn}";} | sed -r -e "${REGEX_ARRAY}" | sed -r -e "${REGEX_HOUR_INTERVAL}" | sed -r -e "${REGEX_INT}" | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | perl -0777 -pe "${PERL_REGEX_ROUND}" |  psql ${CONNSTR}
        fi
    done
done


# generate first_day_sofa table last
echo "Generating ${TARGET_DATASET}.first_day_sofa"
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ${TARGET_DATASET}.first_day_sofa; CREATE TABLE ${TARGET_DATASET}.first_day_sofa AS "; cat firstday/first_day_sofa.sql;} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | sed -r -e "${REGEX_INTERVAL}" | perl -0777 -pe "${PERL_REGEX_ROUND}" |  psql ${CONNSTR}
