# Config
PHYSIONETURL=https://physionet.org/works/MIMICIIIClinicalDatabase/files/
PHYSIONETDEMOURL=https://physionet.org/works/MIMICIIIClinicalDatabaseDemo/

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
DBSCHEMA := mimiciii

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
	@echo 'Makefile for building MIMIC-III in a local Postgres database                '
	@echo '                                                                            '
	@echo 'Usage:                                                                      '
	@echo '                                                                            '
	@echo '   Build MIMIC-III using the CSV files in the /path/to/data directory -     '
	@echo '                                                                            '
	@echo '             make mimic datadir="/path/to/data/"                            '
	@echo '                                                                            '
	@echo '             e.g. make mimic datadir="/data/mimic/v1_3/"                    '
	@echo '                                                                            '
	@echo '   Build MIMIC-III using the .csv.gz files in the /path/to/data directory - '
	@echo '                                                                            '
	@echo '             make mimic-gz datadir="/path/to/data/"                         '
	@echo '                                                                            '
	@echo '             e.g. make mimic-gz datadir="/data/mimic/v1_3/"                 '
	@echo '----------------------------------------------------------------------------'
	@echo '                                                                            '

mimic-gz: mimic-check-gz mimic-build-gz

mimic: mimic-check mimic-build

create-user:
	@echo '-------------------------------------'
	@echo '-- Creating user, database, schema --'
	@echo '-------------------------------------'
	@echo ''
	@sleep 2
	MIMIC_USER="$(DBUSER)" MIMIC_DB="$(DBNAME)" MIMIC_PASSWORD="$(DBPASS)" MIMIC_SCHEMA="$(DBSCHEMA)" DBHOST="$(DBHOST)" DBPORT="$(DBPORT)" ./create_mimic_user.sh

mimic-build-gz:
	@echo '------------------------'
	@echo '-- Building MIMIC-III --'
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

mimic-build:
	@echo '------------------------'
	@echo '-- Building MIMIC-III --'
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

mimic-download:
	@echo '------------------------------------------'
	@echo '-- Downloading MIMIC-III from PhysioNet --'
	@echo '------------------------------------------'
	@echo ''
ifeq ("$(physionetuser)","")
	@echo 'Cannot download data: physionetuser variable is unset.'
	@echo 'Call the makefile again with physionetuser=<USERNAME>'
	@echo ' e.g. make eicu-download datadir=/path/to/data physionetuser=hello@physionet.org'
else
	wget --user $(physionetuser) --ask-password -P $(DATADIR) -A csv.gz -m -p -E -k -K -np -nd "$(PHYSIONETURL)"
endif

mimic-demo-download:
	@echo '------------------------------------------'
	@echo '-- Downloading MIMIC-III from PhysioNet --'
	@echo '------------------------------------------'
	@echo ''
	wget --user $(physionetuser) --ask-password -P $(DATADIR) -A csv.gz -m -p -E -k -K -np -nd "$(PHYSIONETDEMOURL)"

#This is fairly inelegant and could be tidied with a for loop and an if to check for gzip,
#but need to maintain compatibility with Windows, which baffling lacks these things
mimic-check-gz:
	@echo ''
	@echo '-----------------------'
	@echo '-- Checking for data --'
	@echo '-----------------------'
	@echo ''
	@echo 'Data path: ' $(DATADIR)
ifeq ("$(wildcard $(DATADIR)ADMISSIONS.csv.gz)","")
	@echo "Unable to find $(DATADIR)ADMISSIONS.csv.gz - exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)CALLOUT.csv.gz)","")
	@echo "Unable to find $(DATADIR)CALLOUT.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)CAREGIVERS.csv.gz)","")
	@echo "Unable to find $(DATADIR)CAREGIVERS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)CHARTEVENTS.csv.gz)","")
	@echo "Unable to find $(DATADIR)CHARTEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)CPTEVENTS.csv.gz)","")
	@echo "Unable to find $(DATADIR)CPTEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)DATETIMEEVENTS.csv.gz)","")
	@echo "Unable to find $(DATADIR)DATETIMEEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)D_CPT.csv.gz)","")
	@echo "Unable to find $(DATADIR)D_CPT.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)DIAGNOSES_ICD.csv.gz)","")
	@echo "Unable to find $(DATADIR)DIAGNOSES_ICD.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)D_ICD_DIAGNOSES.csv.gz)","")
	@echo "Unable to find $(DATADIR)D_ICD_DIAGNOSES.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)D_ICD_PROCEDURES.csv.gz)","")
	@echo "Unable to find $(DATADIR)D_ICD_PROCEDURES.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)D_ITEMS.csv.gz)","")
	@echo "Unable to find $(DATADIR)D_ITEMS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)D_LABITEMS.csv.gz)","")
	@echo "Unable to find $(DATADIR)D_LABITEMS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)DRGCODES.csv.gz)","")
	@echo "Unable to find $(DATADIR)DRGCODES.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)ICUSTAYS.csv.gz)","")
	@echo "Unable to find $(DATADIR)ICUSTAYS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)INPUTEVENTS_CV.csv.gz)","")
	@echo "Unable to find $(DATADIR)INPUTEVENTS_CV.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)INPUTEVENTS_MV.csv.gz)","")
	@echo "Unable to find $(DATADIR)INPUTEVENTS_MV.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)LABEVENTS.csv.gz)","")
	@echo "Unable to find $(DATADIR)LABEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)MICROBIOLOGYEVENTS.csv.gz)","")
	@echo "Unable to find $(DATADIR)MICROBIOLOGYEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)NOTEEVENTS.csv.gz)","")
	@echo "Unable to find $(DATADIR)NOTEEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)OUTPUTEVENTS.csv.gz)","")
	@echo "Unable to find $(DATADIR)OUTPUTEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)PATIENTS.csv.gz)","")
	@echo "Unable to find $(DATADIR)PATIENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)PRESCRIPTIONS.csv.gz)","")
	@echo "Unable to find $(DATADIR)PRESCRIPTIONS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)PROCEDUREEVENTS_MV.csv.gz)","")
	@echo "Unable to find $(DATADIR)PROCEDUREEVENTS_MV.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)PROCEDURES_ICD.csv.gz)","")
	@echo "Unable to find $(DATADIR)PROCEDURES_ICD.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)SERVICES.csv.gz)","")
	@echo "Unable to find $(DATADIR)SERVICES.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)TRANSFERS.csv.gz)","")
	@echo "Unable to find $(DATADIR)TRANSFERS.csv.gz. Exiting before build."; exit 1
endif
	@echo 'All data present!'
	@echo ''

mimic-check:
	@echo ''
	@echo '-----------------------'
	@echo '-- Checking for data --'
	@echo '-----------------------'
	@echo ''
	@echo 'Data path: ' $(DATADIR)
ifeq ("$(wildcard $(DATADIR)ADMISSIONS.csv)","")
	@echo "Unable to find $(DATADIR)ADMISSIONS.csv - exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)CALLOUT.csv)","")
	@echo "Unable to find $(DATADIR)CALLOUT.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)CAREGIVERS.csv)","")
	@echo "Unable to find $(DATADIR)CAREGIVERS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)CHARTEVENTS.csv)","")
	@echo "Unable to find $(DATADIR)CHARTEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)CPTEVENTS.csv)","")
	@echo "Unable to find $(DATADIR)CPTEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)DATETIMEEVENTS.csv)","")
	@echo "Unable to find $(DATADIR)DATETIMEEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)D_CPT.csv)","")
	@echo "Unable to find $(DATADIR)D_CPT.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)DIAGNOSES_ICD.csv)","")
	@echo "Unable to find $(DATADIR)DIAGNOSES_ICD.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)D_ICD_DIAGNOSES.csv)","")
	@echo "Unable to find $(DATADIR)D_ICD_DIAGNOSES.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)D_ICD_PROCEDURES.csv)","")
	@echo "Unable to find $(DATADIR)D_ICD_PROCEDURES.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)D_ITEMS.csv)","")
	@echo "Unable to find $(DATADIR)D_ITEMS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)D_LABITEMS.csv)","")
	@echo "Unable to find $(DATADIR)D_LABITEMS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)DRGCODES.csv)","")
	@echo "Unable to find $(DATADIR)DRGCODES.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)ICUSTAYS.csv)","")
	@echo "Unable to find $(DATADIR)ICUSTAYS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)INPUTEVENTS_CV.csv)","")
	@echo "Unable to find $(DATADIR)INPUTEVENTS_CV.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)INPUTEVENTS_MV.csv)","")
	@echo "Unable to find $(DATADIR)INPUTEVENTS_MV.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)LABEVENTS.csv)","")
	@echo "Unable to find $(DATADIR)LABEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)MICROBIOLOGYEVENTS.csv)","")
	@echo "Unable to find $(DATADIR)MICROBIOLOGYEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)NOTEEVENTS.csv)","")
	@echo "Unable to find $(DATADIR)NOTEEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)OUTPUTEVENTS.csv)","")
	@echo "Unable to find $(DATADIR)OUTPUTEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)PATIENTS.csv)","")
	@echo "Unable to find $(DATADIR)PATIENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)PRESCRIPTIONS.csv)","")
	@echo "Unable to find $(DATADIR)PRESCRIPTIONS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)PROCEDUREEVENTS_MV.csv)","")
	@echo "Unable to find $(DATADIR)PROCEDUREEVENTS_MV.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)PROCEDURES_ICD.csv)","")
	@echo "Unable to find $(DATADIR)PROCEDURES_ICD.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)SERVICES.csv)","")
	@echo "Unable to find $(DATADIR)SERVICES.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(DATADIR)TRANSFERS.csv)","")
	@echo "Unable to find $(DATADIR)TRANSFERS.csv. Exiting before build."; exit 1
endif
	@echo 'All data present!'
	@echo ''

clean:
	@echo

concepts:
	@echo '------------------------'
	@echo '-- Building MIMIC-III --'
	@echo '------------------------'
	@echo ''
	@echo '---------------------'
	@echo '-- Adding concepts --'
	@echo '---------------------'
	@echo ''
	@sleep 2
	cd ../../concepts/ && psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f make-concepts.sql


.PHONY: help mimic clean
