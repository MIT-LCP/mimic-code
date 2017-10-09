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
  echo "User is unset, using default '$MIMIC_USER'";
else
  echo "User is set to '$MIMIC_USER'";
fi

if hash gosu 2>/dev/null; then
   SUDO='gosu postgres'
else
   SUDO='sudo -u postgres'
fi

# err2 checks if we can login with postgres
err2=`psql postgres postgres -c "select 1;" 2>&1 >/dev/null`

if [[ $err2 == *"Peer authentication failed for user"* ]]; then
  # we need to call sudo every time for postgres
  PSQL=$SUDO' psql'
else
  PSQL='psql'
fi

# step 1) create user, if needed
if [ "$MIMIC_USER" != "postgres" ]; then
    # we need to create this user via postgres
    # use SUDO to login as postgres
    $PSQL postgres postgres -c "DROP USER IF EXISTS $MIMIC_USER; CREATE USER $MIMIC_USER WITH PASSWORD '$MIMIC_PASSWORD';"
fi

if [ "$MIMIC_DB" != "postgres" ]; then
  # drop and recreate the database
  $PSQL postgres postgres -c "DROP DATABASE IF EXISTS $MIMIC_DB;"
  $PSQL postgres postgres -c "CREATE DATABASE $MIMIC_DB OWNER $MIMIC_USER;"
fi

# create the schema on the database
$PSQL $MIMIC_DB postgres -c "CREATE SCHEMA $MIMIC_SCHEMA AUTHORIZATION $MIMIC_USER;"
