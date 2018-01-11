# Config
PHYSIONETURL=https://physionet.org/works/MIMICIIIClinicalDatabase/files/
PHYSIONETDEMOURL=https://physionet.org/works/MIMICIIIClinicalDatabaseDemo/

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
# add ON_ERROR_STOP so scripts stop when they fail
DBSTRING +=  options=--search_path=$(DBSCHEMA)

# if psql version is 10, then we can use declarative partitioning
# this is done in the postgres_create_tables_pg10.sql file
PSQL_MAJOR_VERSION := $$(psql --version | perl -lne 'print "_pg10" if / 10.\d+/')

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
	psql "$(DBSTRING)" -v ON_ERROR_STOP=1 -f postgres_load_data.sql -v mimic_data_dir=${datadir}
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
	wget --user $(physionetuser) --ask-password -P $(datadir) -A csv.gz -m -p -E -k -K -np -nd "$(PHYSIONETURL)"
endif

mimic-demo-download:
	@echo '------------------------------------------'
	@echo '-- Downloading MIMIC-III from PhysioNet --'
	@echo '------------------------------------------'
	@echo ''
	wget --user $(physionetuser) --ask-password -P $(datadir) -A csv.gz -m -p -E -k -K -np -nd "$(PHYSIONETDEMOURL)"

#This is fairly inelegant and could be tidied with a for loop and an if to check for gzip,
#but need to maintain compatibility with Windows, which baffling lacks these things
mimic-check-gz:
	@echo ''
	@echo '-----------------------'
	@echo '-- Checking for data --'
	@echo '-----------------------'
	@echo ''
	@echo 'Data path: ' $(datadir)
ifeq ("$(wildcard $(datadir)ADMISSIONS.csv.gz)","")
	@echo "Unable to find $(datadir)ADMISSIONS.csv.gz - exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)CALLOUT.csv.gz)","")
	@echo "Unable to find $(datadir)CALLOUT.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)CAREGIVERS.csv.gz)","")
	@echo "Unable to find $(datadir)CAREGIVERS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)CHARTEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)CHARTEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)CPTEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)CPTEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)DATETIMEEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)DATETIMEEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)D_CPT.csv.gz)","")
	@echo "Unable to find $(datadir)D_CPT.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)DIAGNOSES_ICD.csv.gz)","")
	@echo "Unable to find $(datadir)DIAGNOSES_ICD.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)D_ICD_DIAGNOSES.csv.gz)","")
	@echo "Unable to find $(datadir)D_ICD_DIAGNOSES.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)D_ICD_PROCEDURES.csv.gz)","")
	@echo "Unable to find $(datadir)D_ICD_PROCEDURES.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)D_ITEMS.csv.gz)","")
	@echo "Unable to find $(datadir)D_ITEMS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)D_LABITEMS.csv.gz)","")
	@echo "Unable to find $(datadir)D_LABITEMS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)DRGCODES.csv.gz)","")
	@echo "Unable to find $(datadir)DRGCODES.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)ICUSTAYS.csv.gz)","")
	@echo "Unable to find $(datadir)ICUSTAYS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)INPUTEVENTS_CV.csv.gz)","")
	@echo "Unable to find $(datadir)INPUTEVENTS_CV.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)INPUTEVENTS_MV.csv.gz)","")
	@echo "Unable to find $(datadir)INPUTEVENTS_MV.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)LABEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)LABEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)MICROBIOLOGYEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)MICROBIOLOGYEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)NOTEEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)NOTEEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)OUTPUTEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)OUTPUTEVENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)PATIENTS.csv.gz)","")
	@echo "Unable to find $(datadir)PATIENTS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)PRESCRIPTIONS.csv.gz)","")
	@echo "Unable to find $(datadir)PRESCRIPTIONS.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)PROCEDUREEVENTS_MV.csv.gz)","")
	@echo "Unable to find $(datadir)PROCEDUREEVENTS_MV.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)PROCEDURES_ICD.csv.gz)","")
	@echo "Unable to find $(datadir)PROCEDURES_ICD.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)SERVICES.csv.gz)","")
	@echo "Unable to find $(datadir)SERVICES.csv.gz. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)TRANSFERS.csv.gz)","")
	@echo "Unable to find $(datadir)TRANSFERS.csv.gz. Exiting before build."; exit 1
endif
	@echo 'All data present!'
	@echo ''

mimic-check:
	@echo ''
	@echo '-----------------------'
	@echo '-- Checking for data --'
	@echo '-----------------------'
	@echo ''
	@echo 'Data path: ' $(datadir)
ifeq ("$(wildcard $(datadir)ADMISSIONS.csv)","")
	@echo "Unable to find $(datadir)ADMISSIONS.csv - exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)CALLOUT.csv)","")
	@echo "Unable to find $(datadir)CALLOUT.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)CAREGIVERS.csv)","")
	@echo "Unable to find $(datadir)CAREGIVERS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)CHARTEVENTS.csv)","")
	@echo "Unable to find $(datadir)CHARTEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)CPTEVENTS.csv)","")
	@echo "Unable to find $(datadir)CPTEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)DATETIMEEVENTS.csv)","")
	@echo "Unable to find $(datadir)DATETIMEEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)D_CPT.csv)","")
	@echo "Unable to find $(datadir)D_CPT.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)DIAGNOSES_ICD.csv)","")
	@echo "Unable to find $(datadir)DIAGNOSES_ICD.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)D_ICD_DIAGNOSES.csv)","")
	@echo "Unable to find $(datadir)D_ICD_DIAGNOSES.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)D_ICD_PROCEDURES.csv)","")
	@echo "Unable to find $(datadir)D_ICD_PROCEDURES.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)D_ITEMS.csv)","")
	@echo "Unable to find $(datadir)D_ITEMS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)D_LABITEMS.csv)","")
	@echo "Unable to find $(datadir)D_LABITEMS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)DRGCODES.csv)","")
	@echo "Unable to find $(datadir)DRGCODES.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)ICUSTAYS.csv)","")
	@echo "Unable to find $(datadir)ICUSTAYS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)INPUTEVENTS_CV.csv)","")
	@echo "Unable to find $(datadir)INPUTEVENTS_CV.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)INPUTEVENTS_MV.csv)","")
	@echo "Unable to find $(datadir)INPUTEVENTS_MV.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)LABEVENTS.csv)","")
	@echo "Unable to find $(datadir)LABEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)MICROBIOLOGYEVENTS.csv)","")
	@echo "Unable to find $(datadir)MICROBIOLOGYEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)NOTEEVENTS.csv)","")
	@echo "Unable to find $(datadir)NOTEEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)OUTPUTEVENTS.csv)","")
	@echo "Unable to find $(datadir)OUTPUTEVENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)PATIENTS.csv)","")
	@echo "Unable to find $(datadir)PATIENTS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)PRESCRIPTIONS.csv)","")
	@echo "Unable to find $(datadir)PRESCRIPTIONS.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)PROCEDUREEVENTS_MV.csv)","")
	@echo "Unable to find $(datadir)PROCEDUREEVENTS_MV.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)PROCEDURES_ICD.csv)","")
	@echo "Unable to find $(datadir)PROCEDURES_ICD.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)SERVICES.csv)","")
	@echo "Unable to find $(datadir)SERVICES.csv. Exiting before build."; exit 1
endif
ifeq ("$(wildcard $(datadir)TRANSFERS.csv)","")
	@echo "Unable to find $(datadir)TRANSFERS.csv. Exiting before build."; exit 1
endif
	@echo 'All data present!'
	@echo ''

clean:
	@echo

.PHONY: help mimic clean
