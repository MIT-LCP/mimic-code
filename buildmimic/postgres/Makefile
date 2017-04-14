# Config
PHYSIONETURL=https://physionet.org/works/MIMICIIIClinicalDatabase/files/

# The following check whether values are passed via environment, set to defaults if not
ifeq ($(DBNAME),)
DBNAME := mimic
endif

ifeq ($(DBUSER),)
DBUSER := postgres
endif

# Specify the password here
# If you don't specify a password, then the role will not require one to login via password authentication
#DBPASS=

# Change "mimiciii" to specify a different schema
DBSCHEMA := mimiciii

# NOTE: you do not need to specify localhost/port
# in fact, this is detrimental if you want to use peer authentication, as "localhost" is not strictly local
#DBHOST := localhost
#DBPORT := 5432

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
DBSTRING +=  options=--search_path=$(DBSCHEMA)

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

mimic-gz: mimic-check-gz create-user mimic-build-gz

mimic: mimic-check create-user mimic-build

create-user:
	@echo '------------------------'
	@echo '-- Building MIMIC-III --'
	@echo '------------------------'
	@echo ''
	@sleep 2
	MIMIC_USER="$(DBUSER)" MIMIC_DB="$(DBNAME)" MIMIC_PASSWORD="$(DBPASS)" MIMIC_SCHEMA="$(DBSCHEMA)" ./create_mimic_user.sh

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
	psql "$(DBSTRING)" -f postgres_create_tables.sql
	@echo ''
	@echo '------------------'
	@echo '-- Loading data --'
	@echo '------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -f postgres_load_data_gz.sql -v mimic_data_dir=${datadir}
	@echo ''
	@echo '--------------------'
	@echo '-- Adding indexes --'
	@echo '--------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -f postgres_add_indexes.sql
	@echo ''
	@echo '--------------------'
	@echo '-- Adding comments --'
	@echo '--------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -f postgres_add_comments.sql
	@echo ''
	@echo '----------------'
	@echo '-- Check data --'
	@echo '----------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -f postgres_checks.sql

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
	psql "$(DBSTRING)" -f postgres_create_tables.sql
	@echo ''
	@echo '------------------'
	@echo '-- Loading data --'
	@echo '------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -f postgres_load_data.sql -v mimic_data_dir=${datadir}
	@echo ''
	@echo '--------------------'
	@echo '-- Adding indexes --'
	@echo '--------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -f postgres_add_indexes.sql
	@echo ''
	@echo '--------------------'
	@echo '-- Adding comments --'
	@echo '--------------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -f postgres_add_comments.sql
	@echo ''
	@echo '----------------'
	@echo '-- Check data --'
	@echo '----------------'
	@echo ''
	@sleep 2
	psql "$(DBSTRING)" -f postgres_checks.sql

mimic-download:
	@echo '------------------------------------------'
	@echo '-- Downloading MIMIC-III from PhysioNet --'
	@echo '------------------------------------------'
	@echo ''
	wget --user ${physionetuser} --ask-password -P ${datadir} -A csv.gz -m -p -E -k -K -np -nd  "$(PHYSIONETURL)"


#This is fairly inelegant and could be tidied with a for loop and an if to check for gzip,
#but need to maintain compatability with Windows, which baffling lacks these things
mimic-check-gz:
	@echo ''
	@echo '-----------------------'
	@echo '-- Checking for data --'
	@echo '-----------------------'
	@echo ''
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
