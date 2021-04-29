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

PSQL='psql'

# add in the host/port, if they were specified (not null, -n)
# omitted the "+x" so we treat an empty string as equivalent to unset variable
if [ -n "${DBHOST}" ]; then
  echo "Adding DBHOST ${DBHOST}"
  PSQL=$PSQL' -h '$DBHOST
fi

if [ -n "${DBPORT}" ]; then
  echo "Adding DBPORT ${DBPORT}"
  PSQL=$PSQL' -p '$DBPORT
fi

if hash gosu 2>/dev/null; then
   SUDO='gosu postgres'
else
   SUDO='sudo -u postgres'
fi

# check if SUDO is needed by checking if we can login with postgres without it
err2=`psql postgres postgres -c "select 1;" 2>&1 >/dev/null`

if [[ $err2 == *"Peer authentication failed for user"* ]]; then
  # we need to call sudo every time for postgres
  echo 'Not logged in as postgres user. Script will require sudo.'

  echo "*** Ignore any warnings of the form: 'could not change directory to...' ***"
  echo "These indicate you are running the script in a folder that the postgres user does not have access to."
  echo "The script will still work - so these warnings can be safely ignored."

  PSQL=$SUDO' '$PSQL
fi

# step 1) create user, if needed
if [ "$MIMIC_USER" != "postgres" ]; then
    # we need to create this user via postgres
    # use SUDO to login as postgres
    $PSQL -U postgres -d postgres -c "DROP USER IF EXISTS $MIMIC_USER; CREATE USER $MIMIC_USER WITH PASSWORD '$MIMIC_PASSWORD';"
fi

if [ "$MIMIC_DB" != "postgres" ]; then
  # drop and recreate the database
  $PSQL -U postgres -d postgres -c "DROP DATABASE IF EXISTS $MIMIC_DB;"
  $PSQL -U postgres -d postgres -c "CREATE DATABASE $MIMIC_DB OWNER $MIMIC_USER;"
fi