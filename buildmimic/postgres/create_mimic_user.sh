#!/bin/bash
set -e

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
  echo "User is unset, using default '$MIMIC_USER'";
else
  echo "User is set to '$MIMIC_USER'";
fi

# if hash gosu 2>/dev/null; then
#     SUDO='gosu postgres'
# else
#     SUDO='sudo -u postgres'
# fi

echo "$MIMIC_USER"
if [ "$MIMIC_USER" != "postgres" ]; then
  # create user
  psql postgres postgres -c "DROP USER IF EXISTS $MIMIC_USER;"
  psql postgres postgres -c "CREATE USER $MIMIC_USER WITH PASSWORD '$MIMIC_PASSWORD';"
fi

# create database
echo
psql postgres postgres -c "DROP DATABASE IF EXISTS $MIMIC_DB;"
psql postgres postgres -c "CREATE DATABASE $MIMIC_DB OWNER $MIMIC_USER;"

# create schema on database
export PGPASSWORD=$MIMIC_PASSWORD
psql -U $MIMIC_USER -d ${MIMIC_DB} -c "CREATE SCHEMA $MIMIC_SCHEMA AUTHORIZATION $MIMIC_USER;"
