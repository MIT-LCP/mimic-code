#!/bin/bash

if [ -z ${MIMIC_PASSWORD+x} ]; then
  echo "MIMIC_PASSWORD is unset";
  exit 1
else
  echo "MIMIC_PASSWORD is set";
fi

if [ -z ${MIMIC_DB+x} ]; then
  MIMIC_DB=mimic
  echo "MIMIC_DB is unset, using default '$MIMIC_DB'";
else
  echo "MIMIC_DB is set to '$MIMIC_DB'";
fi

if [ -z ${MIMIC_USER+x} ]; then
  MIMIC_USER=postgres
  echo "MIMIC_USER is unset, using default '$MIMIC_USER'";
else
  echo "MIMIC_USER is set to '$MIMIC_USER'";
fi

# if hash gosu 2>/dev/null; then
#     SUDO='gosu postgres'
# else
#     SUDO='sudo -u postgres'
# fi

$SUDO psql postgres > /dev/null <<- EOSQL
    CREATE USER $MIMIC_USER WITH PASSWORD '$MIMIC_PASSWORD';
    DROP DATABASE IF EXISTS $MIMIC_DB;
    CREATE DATABASE $MIMIC_DB OWNER $MIMIC_USER;
    CREATE SCHEMA $MIMIC_SCHEMA AUTHORIZATION $MIMIC_USER;
EOSQL
