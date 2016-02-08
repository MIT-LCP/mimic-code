BASEDIR=$(CURDIR)
INPUTDIR=$(BASEDIR)/source
OUTPUTDIR=$(BASEDIR)/output

# Config
DBNAME=mimic
DBUSER=postgres
DBPASS=

help:
	@echo '                                                                           '
	@echo '---------------------------------------------------------------------------'
	@echo 'Makefile for building MIMIC-III in a local Postgres database               '
	@echo '                                                                           '
	@echo 'Usage:                                                                     '
	@echo '                                                                           '
	@echo '   Build MIMIC-III using the CSV files in the /path/to/data directory -    '
	@echo '                                                                           '
	@echo '             make mimic datadir="/path/to/data/"                           '
	@echo '                                                                           '
	@echo '             e.g. make mimic datadir="/data/mimic/v1_3/"                   '
	@echo '---------------------------------------------------------------------------'
	@echo '                                                                           '

mimic:
	@echo ''
	@echo '------------------------'
	@echo '-- Building MIMIC-III --'
	@echo '------------------------'
	@echo ''
	@sleep 2
	MIMIC_USER="$(DBUSER)" MIMIC_DB="$(DBNAME)" MIMIC_PASSWORD="$(DBPASS)" ./create_mimic_user.sh
	@echo ''
	@echo '---------------------'
	@echo '-- Creating tables --'
	@echo '---------------------'
	@echo ''
	@sleep 2
	psql -f postgres_create_tables.sql --dbname="$(DBNAME)" --username="$(DBUSER)"
	@echo ''
	@echo '------------------'
	@echo '-- Loading data --'
	@echo '------------------'
	@echo ''
	@sleep 2
	psql -f postgres_load_data.sql -v mimic_data_dir=${datadir} --dbname="$(DBNAME)" --username="$(DBUSER)"
	@echo ''
	@echo '--------------------'
	@echo '-- Adding indexes --'
	@echo '--------------------'
	@echo ''
	@sleep 2
	psql -f postgres_add_indexes.sql --dbname="$(DBNAME)" --username="$(DBUSER)"

.PHONY: help mimic
