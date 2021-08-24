#!/bin/bash

set -e

# This script generates all the concepts as MATERIALIZED VIEWs in 
# mimic_derived schema for Postgres.

# We assume username, password, databse name and port as follows. 
# Modify according to your case
export USER='postgres'
export PGPASSWORD='postgres'
export DB='mimiciv'
export PORT='5432'
#export CONNSTR='-d mimiciv'
export TARGET_SCHEMA='mimic_iv_derived'

# this is set as the search_path variable for psql
# a search path of "mimic_iv_derived,mimic_core,mimic_hosp,mimic_icu" will 
# search all mimic-iv data but will create tables on the mimic_iv_derived schema
export PSQL_PREAMBLE='SET search_path TO mimic_iv_derived,mimic_core,mimic_hosp,mimic_icu'

export REGEX_SCHEMA='s/`physionet-data.(mimic_derived|mimic_core|mimic_hosp|mimic_icu).(.+?)`/\2/g'

# this command will remove the mimic_iv_derived schema along with any data in 
# it first and then create it again from scratch
psql -X -v ON_ERROR_STOP=ON -U ${USER} -p ${PORT} -d ${DB} -c \
    "DROP SCHEMA IF EXISTS ${TARGET_SCHEMA} CASCADE;" -c \
    "CREATE SCHEMA ${TARGET_SCHEMA};" -f \
    functions-postgres.sql

# generate tables in subfolders
# order of the folders is important for a few tables here:
# * firstday should go last
# * scores (sofa et al) depends on labs
# * sepsis depends on score (sofa.sql in particular)
# * organfailure depends on measurement

for d in demographics comorbidity measurement medication treatment organfailure;
do
    for fn in `ls $d`;
    do
        # only run SQL queries
        if [[ "${fn: -4}" == ".sql" ]]; then
            # table name is file name minus extension
            tbl=`echo $fn | rev | cut -d. -f2- | rev`
            # icustay_hourly depends on icustay_times thus should be delayed
            if [[ "${tbl}" == "icustay_hourly" ]]; then
                continue
            # skip meld as it depends on other firstday queries
            elif [[ "${tbl}" == "meld" ]]; then
                continue
            # uo_rate depends on uo thus should be delayed
            elif [[ "${tbl}" == "urine_output_rate" ]]; then
                continue
            # kdigo_stages needs to be run after creat/uo
            elif [[ "${tbl}" == "kdigo_stages" ]]; then
                continue
            fi
            echo "##################################";
            echo "Generating ${TARGET_SCHEMA}.${tbl}";
            { echo "${PSQL_PREAMBLE}; ";
            echo "DROP MATERIALIZED VIEW IF EXISTS ${tbl} CASCADE;";
            echo "CREATE MATERIALIZED VIEW ${tbl} AS ";
            cat ${d}/${fn}; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql -X -v ON_ERROR_STOP=ON -U ${USER} -p ${PORT} -d ${DB}
        fi
    done
done

# generate icustay_hourly table
export folder='demographics'
export sqlfile='icustay_hourly'
echo "########################################"
echo "Generating ${TARGET_SCHEMA}."
{ echo "${PSQL_PREAMBLE};";
  echo "DROP MATERIALIZED VIEW IF EXISTS ${TARGET_SCHEMA}.${sqlfile} CASCADE;";
  echo "CREATE MATERIALIZED VIEW ${TARGET_SCHEMA}.${sqlfile} AS ";
  cat ${folder}/${sqlfile}.sql;
} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql -X -v ON_ERROR_STOP=ON -U ${USER} -p ${PORT} -d ${DB}
# generate uo_rate table
export folder='measurement'
export sqlfile='urine_output_rate'
echo "########################################"
echo "Generating ${TARGET_SCHEMA}."
{ echo "${PSQL_PREAMBLE};";
  echo "DROP MATERIALIZED VIEW IF EXISTS ${TARGET_SCHEMA}.${sqlfile} CASCADE;";
  echo "CREATE MATERIALIZED VIEW ${TARGET_SCHEMA}.${sqlfile} AS ";
  cat ${folder}/${sqlfile}.sql;
} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql -X -v ON_ERROR_STOP=ON -U ${USER} -p ${PORT} -d ${DB}

# sofa depends on icustay_hourly
for d in firstday score sepsis;
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
            # skip sepsis3 as it depends on sus and sofa which is not available now
            elif [[ "${tbl}" == "sepsis3" ]]; then
                continue
            fi
            echo "########################################"
            echo "Generating ${TARGET_SCHEMA}.${tbl}"
            { echo "${PSQL_PREAMBLE};";
              echo "DROP MATERIALIZED VIEW IF EXISTS ${tbl} CASCADE;";
              echo "CREATE MATERIALIZED VIEW ${tbl} AS ";
              cat ${d}/${fn}; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql -X -v ON_ERROR_STOP=ON -U ${USER} -p ${PORT} -d ${DB}
       fi
    done
done

# generate first_day_sofa table
export folder='firstday'
export sqlfile='first_day_sofa'
echo "########################################"
echo "Generating ${TARGET_SCHEMA}.${sqlfile}"
{ echo "${PSQL_PREAMBLE};";
  echo "DROP MATERIALIZED VIEW IF EXISTS ${TARGET_SCHEMA}.${sqlfile} CASCADE;";
  echo "CREATE MATERIALIZED VIEW ${TARGET_SCHEMA}.${sqlfile} AS ";
  cat ${folder}/${sqlfile}.sql;
} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql -X -v ON_ERROR_STOP=ON -U ${USER} -p ${PORT} -d ${DB}
# meld can be generated as soon as first_day_* are available 
export folder='organfailure'
export sqlfile='meld'
echo "########################################"
echo "Generating ${TARGET_SCHEMA}.${sqlfile}"
{ echo "${PSQL_PREAMBLE};";
  echo "DROP MATERIALIZED VIEW IF EXISTS ${TARGET_SCHEMA}.${sqlfile} CASCADE;";
  echo "CREATE MATERIALIZED VIEW ${TARGET_SCHEMA}.${sqlfile} AS ";
  cat ${folder}/${sqlfile}.sql;
} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql -X -v ON_ERROR_STOP=ON -U ${USER} -p ${PORT} -d ${DB}

# sepsis3
export folder='sepsis'
export sqlfile='sepsis3'
echo "########################################"
echo "Generating ${TARGET_SCHEMA}.${sqlfile}"
{ echo "${PSQL_PREAMBLE};";
  echo "DROP MATERIALIZED VIEW IF EXISTS ${TARGET_SCHEMA}.${sqlfile} CASCADE;";
  echo "CREATE MATERIALIZED VIEW ${TARGET_SCHEMA}.${sqlfile} AS ";
  cat ${folder}/${sqlfile}.sql;
} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql -X -v ON_ERROR_STOP=ON -U ${USER} -p ${PORT} -d ${DB}
#  kdigo_stages last
export folder='organfailure'
export sqlfile='kdigo_stages'
echo "########################################"
echo "Generating ${TARGET_SCHEMA}.${sqlfile}"
{ echo "${PSQL_PREAMBLE};";
  echo "DROP MATERIALIZED VIEW IF EXISTS ${TARGET_SCHEMA}.${sqlfile} CASCADE;";
  echo "CREATE MATERIALIZED VIEW ${TARGET_SCHEMA}.${sqlfile} AS ";
  cat ${folder}/${sqlfile}.sql;
} | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql -X -v ON_ERROR_STOP=ON -U ${USER} -p ${PORT} -d ${DB}
