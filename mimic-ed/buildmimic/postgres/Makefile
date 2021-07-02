# Config
PHYSIONETURL=https://physionet.org/files/mimic-iv-ed/1.0/
#PHYSIONETDEMOURL=https://physionet.org/works/MIMICIIIClinicalDatabaseDemo/

# Ensure that datadir ends in a slash
DATADIR := $(dir $(datadir))
ifneq ($(datadir),$(DATADIR))
DATADIR := $(datadir)/
endif


# Set the following parameters to defaults
# These will be overwritten by settings passed to the makefile
DBNAME := mimic
DBUSER := postgres
DBPASS := postgres
DBSCHEMA := mimicived

# NOTE: you do not need to specify localhost/port
# in fact, this is detrimental if you want to use peer authentication
# "localhost" uses a loopback, so peer authentication doesn't work with it
DBHOST :=
DBPORT :=

# when connecting, we use a single variable: DBSTRING
# **do not modify this**
# the create_mimic_user.sh script uses the above variables to create the DB/users
# so it's important to keep this DBSTRING consistent
DBSTRING := dbname=$(DBNAME) user=$(DBUSER)
ifneq ($(DBHOST),)
DBSTRING +=  host=$(DBHOST)
endif
ifneq ($(DBPORT),)
DBSTRING +=  port=$(DBPORT)
endif
ifneq ($(DBPASS),)
DBSTRING +=  password=$(DBPASS)
endif
# add ON_ERROR_STOP so scripts stop when they fail
DBSTRING +=  options=--search_path=$(DBSCHEMA)

# if psql version is greater than 10, then we can use declarative partitioning
# this is done in the postgres_create_tables_pg10.sql file
PSQL_SERVER_VERSION := $(shell echo SHOW SERVER_VERSION_NUM | psql "$(DBSTRING)" -At)
PSQL_SERVER_GREATER_THAN_10 := $(shell /usr/bin/test $(PSQL_SERVER_VERSION) -ge 100000 ; echo $$?)
ifeq ($(PSQL_SERVER_GREATER_THAN_10),0)
        PSQL_MAJOR_VERSION := _pg10
endif

help:
	@echo '                                                                            '
	@echo '----------------------------------------------------------------------------'
	@echo 'Makefile for building MIMIC-IV-ED in a local Postgres database              '
	@echo '                                                                            '
	@echo 'Usage:                                                                      '
	@echo '                                                                            '
	@echo '   Build MIMIC-ED using the CSV files in the /path/to/data directory -      '
	@echo '                                                                            '
	@echo '             make mimic-iv-ed datadir="/path/to/data/"                      '
	@echo '                                                                            '
	@echo '             e.g. make mimic-iv-ed datadir="/data/mimic-iv-ed-1.0/csv/"     '
	@echo '                                                                            '
	@echo '   Build MIMIC-ED using the .csv.gz files in the /path/to/data directory -  '
	@echo '                                                                            '
	@echo '             make mimic-iv-ed-gz datadir="/path/to/data/"                   '
	@echo '                                                                            '
	@echo '             e.g. make mimic-iv-ed-gz datadir="/data/mimic-iv-ed-1.0/"      '
	@echo '----------------------------------------------------------------------------'
	@echo '                                                                            '

mimic-iv-ed-gz: mimic-iv-ed-check-gz mimic-iv-ed-build-gz

mimic-iv-ed: mimic-iv-ed-check mimic-iv-ed-build

create-user:
	@echo '-------------------------------------'
	@echo '-- Creating user, database, schema --'
	@echo '-------------------------------------'
	@echo ''
	@sleep 2
	MIMIC_USER="$(DBUSER)" MIMIC_DB="$(DBNAME)" MIMIC_PASSWORD="$(DBPASS)" MIMIC_SCHEMA="$(DBSCHEMA)" DBHOST="$(DBHOST)" DBPORT="$(DBPORT)" ./create_mimic_user.sh

mimic-iv-ed-build-gz:
	@echo '--------------------------'
	@echo '-- Building MIMIC-IV-ED --'
	@echo '--------------------------'
	@echo ''
	@echo '---------------------'
	@echo '-- Creating schema --'
	@echo '---------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -c "DROP SCHEMA IF EXISTS $(DBSCHEMA); CREATE SCHEMA $(DBSCHEMA);"
	@echo ''
	@echo '---------------------'
	@echo '-- Creating tables --'
	@echo '---------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f postgres_create_tables$(PSQL_MAJOR_VERSION).sql
	@echo ''
	@echo '------------------'
	@echo '-- Loading data --'
	@echo '------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f postgres_load_data_gz.sql -v mimic_data_dir=${datadir}
	@echo ''
	@echo '--------------------'
	@echo '-- Adding indexes --'
	@echo '--------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f postgres_add_indexes.sql
	@echo ''
	@echo '--------------------'
	@echo '-- Adding comments --'
	@echo '--------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f postgres_add_comments.sql
	@echo ''
	@echo '----------------'
	@echo '-- Check data --'
	@echo '----------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f postgres_checks.sql

mimic-iv-ed-build:
	@echo '------------------------'
	@echo '-- Building MIMIC-ED ---'
	@echo '------------------------'
	@echo ''
	@echo '---------------------'
	@echo '-- Creating schema --'
	@echo '---------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -c "DROP SCHEMA IF EXISTS $(DBSCHEMA); CREATE SCHEMA $(DBSCHEMA);"
	@echo ''
	@echo '---------------------'
	@echo '-- Creating tables --'
	@echo '---------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f postgres_create_tables$(PSQL_MAJOR_VERSION).sql
	@echo ''
	@echo '------------------'
	@echo '-- Loading data --'
	@echo '------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f postgres_load_data.sql -v mimic_data_dir=${DATADIR}
	@echo ''
	@echo '--------------------'
	@echo '-- Adding indexes --'
	@echo '--------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f postgres_add_indexes.sql
	@echo ''
	@echo '--------------------'
	@echo '-- Adding comments --'
	@echo '--------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f postgres_add_comments.sql
	@echo ''
	@echo '----------------'
	@echo '-- Check data --'
	@echo '----------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f postgres_checks.sql

mimic-iv-ed-download:
	@echo '------------------------------------------'
	@echo '-- Downloading MIMIC-ED from PhysioNet ---'
	@echo '------------------------------------------'
	@echo ''
ifeq ("$(physionetuser)","")
	@echo 'Cannot download data: physionetuser variable is unset.'
	@echo 'Call the makefile again with physionetuser=<USERNAME>'
	@echo ' e.g. make mimic-ed-download datadir=/path/to/data physionetuser=hello@physionet.org'
else
	wget --user $(physionetuser) --ask-password -P $(DATADIR) -A csv.gz -m -p -E -k -K -np -nd "$(PHYSIONETURL)"
endif

#mimic-demo-download:
#	@echo '------------------------------------------'
#	@echo '-- Downloading MIMIC-ED from PhysioNet ---'
#	@echo '------------------------------------------'
#	@echo ''
#	wget --user $(physionetuser) --ask-password -P $(DATADIR) -A csv.gz -m -p -E -k -K -np -nd "$(PHYSIONETDEMOURL)"

#This is fairly inelegant and could be tidied with a for loop and an if to check for gzip,
#but need to maintain compatibility with Windows, which baffling lacks these things
mimic-iv-ed-check-gz:
	@echo ''
	@echo '-----------------------'
	@echo '-- Checking for data --'
	@echo '-----------------------'
	@echo ''
	@echo 'Data path: ' $(DATADIR)
ifeq ("$(wildcard $(DATADIR)diagnosis.csv.gz)","")
	@echo "Unable to find $(DATADIR)DIAGNOSIS.csv.gz - exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)edstays.csv.gz)","")
	@echo "Unable to find $(DATADIR)EDSTAYS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)medrecon.csv.gz)","")
	@echo "Unable to find $(DATADIR)MEDRECON.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)pyxis.csv.gz)","")
	@echo "Unable to find $(DATADIR)PYXIS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)triage.csv.gz)","")
	@echo "Unable to find $(DATADIR)TRIAGE.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)vitalsign.csv.gz)","")
	@echo "Unable to find $(DATADIR)VITALSIGN.csv.gz. Exiting before build."; exit 1
endif
	@echo 'All data present!'
	@echo ''

mimic-iv-ed-check:
	@echo ''
	@echo '-----------------------'
	@echo '-- Checking for data --'
	@echo '-----------------------'
	@echo ''
	@echo 'Data path: ' $(DATADIR)
ifeq ("$(wildcard $(DATADIR)diagnosis.csv)","")
	@echo "Unable to find $(DATADIR)DIAGNOSIS.csv - exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)edstays.csv)","")
	@echo "Unable to find $(DATADIR)EDSTAYS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)medrecon.csv)","")
	@echo "Unable to find $(DATADIR)MEDRECON.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)pyxis.csv)","")
	@echo "Unable to find $(DATADIR)PYXIS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)triage.csv)","")
	@echo "Unable to find $(DATADIR)TRIAGE.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)vitalsign.csv)","")
	@echo "Unable to find $(DATADIR)VITALSIGN.csv. Exiting before build."; exit 1
endif
	@echo 'All data present!'
	@echo ''

clean:
	@echo

.PHONY: help mimic-iv-ed clean
