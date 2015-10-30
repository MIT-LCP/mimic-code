#!/bin/bash

echo 'CREATING MIMIC ... '

if [ $BUILD_MIMIC -eq 1 ]
then
        echo "running create mimic user"

	gosu postgres pg_ctl stop

	gosu postgres pg_ctl -D "$PGDATA" \
		-o "-c listen_addresses='' -c checkpoint_segments=256 -c checkpoint_timeout=600" \
		-w start

	source /docker-entrypoint-initdb.d/mimic_build_files/create_mimic_user.sh

	echo "$0: running postgres_create_tables.sql"
	psql --username "$POSTGRES_USER" --dbname mimic < /docker-entrypoint-initdb.d/mimic_build_files/postgres_create_tables.sql 

	echo "$0: running postgres_add_indexes.sql"
	psql --username "$POSTGRES_USER" --dbname mimic < /docker-entrypoint-initdb.d/mimic_build_files/postgres_add_indexes.sql

	echo "$0: running postgres_add_constraints.sql"
	psql --username "$POSTGRES_USER" --dbname mimic < /docker-entrypoint-initdb.d/mimic_build_files/postgres_add_constraints.sql
fi

echo 'Done!'
