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

# err checks if we can login
err=`psql $MIMIC_DB $MIMIC_USER -c "select 1;" 2>&1`

# err2 checks if we can login with postgres
err2=`psql postgres postgres -c "select 1;" 2>&1`

if [ $err == *"authentication failed for user"* ]; then
  # we need to create this user via postgres
  if [ $err2 == *"Peer authentication failed for user"* ]; then
    # create user
    sudo -u postgres psql postgres postgres -c "DROP USER IF EXISTS $MIMIC_USER; CREATE USER $MIMIC_USER WITH PASSWORD '$MIMIC_PASSWORD';"
  else
    psql postgres postgres -c "DROP USER IF EXISTS $MIMIC_USER; CREATE USER $MIMIC_USER WITH PASSWORD '$MIMIC_PASSWORD';"
  fi
fi


if [ $err == *"FATAL: database"* ]; then
  # we need to create the database for the user
  if [ $err2 == *"Peer authentication failed for user"* ]; then
    # create user
    sudo -u postgres psql postgres postgres -c "DROP USER IF EXISTS $MIMIC_USER; CREATE USER $MIMIC_USER WITH PASSWORD '$MIMIC_PASSWORD';"
  else
    psql postgres postgres -c "DROP USER IF EXISTS $MIMIC_USER; CREATE USER $MIMIC_USER WITH PASSWORD '$MIMIC_PASSWORD';"
  fi
else
  psql postgres $MIMIC_USER -c "DROP DATABASE IF EXISTS $MIMIC_DB; CREATE DATABASE $MIMIC_DB OWNER $MIMIC_USER;"
fi

# create schema on database
export PGPASSWORD=$MIMIC_PASSWORD
psql -U $MIMIC_USER -d ${MIMIC_DB} -c "CREATE SCHEMA $MIMIC_SCHEMA AUTHORIZATION $MIMIC_USER;"
