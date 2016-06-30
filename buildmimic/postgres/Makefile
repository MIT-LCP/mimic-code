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


mimic: mimic-check mimic-build

mimic-build:
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



mimic-check:
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
	@echo "Unable to find $(datadir)CAREGIVERS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)CHARTEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)CHARTEVENTS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)CPTEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)CPTEVENTS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)DATETIMEEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)DATETIMEEVENTS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)D_CPT.csv.gz)","")
	@echo "Unable to find $(datadir)D_CPT.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)DIAGNOSES_ICD.csv.gz)","")
	@echo "Unable to find $(datadir)DIAGNOSES_ICD.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)D_ICD_DIAGNOSES.csv.gz)","")
	@echo "Unable to find $(datadir)D_ICD_DIAGNOSES.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)D_ICD_PROCEDURES.csv.gz)","")
	@echo "Unable to find $(datadir)D_ICD_PROCEDURES.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)D_ITEMS.csv.gz)","")
	@echo "Unable to find $(datadir)D_ITEMS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)D_LABITEMS.csv.gz)","")
	@echo "Unable to find $(datadir)D_LABITEMS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)DRGCODES.csv.gz)","")
	@echo "Unable to find $(datadir)DRGCODES.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)ICUSTAYS.csv.gz)","")
	@echo "Unable to find $(datadir)ICUSTAYS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)INPUTEVENTS_CV.csv.gz)","")
	@echo "Unable to find $(datadir)INPUTEVENTS_CV.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)INPUTEVENTS_MV.csv.gz)","")
	@echo "Unable to find $(datadir)INPUTEVENTS_MV.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)LABEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)LABEVENTS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)MICROBIOLOGYEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)MICROBIOLOGYEVENTS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)NOTEEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)NOTEEVENTS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)OUTPUTEVENTS.csv.gz)","")
	@echo "Unable to find $(datadir)OUTPUTEVENTS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)PATIENTS.csv.gz)","")
	@echo "Unable to find $(datadir)PATIENTS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)PRESCRIPTIONS.csv.gz)","")
	@echo "Unable to find $(datadir)PRESCRIPTIONS.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)PROCEDUREEVENTS_MV.csv.gz)","")
	@echo "Unable to find $(datadir)PROCEDUREEVENTS_MV.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)PROCEDURES_ICD.csv.gz)","")
	@echo "Unable to find $(datadir)PROCEDURES_ICD.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)SERVICES.csv.gz)","")
	@echo "Unable to find $(datadir)SERVICES.csv.gz. Exiting before build."; exit1
endif
ifeq ("$(wildcard $(datadir)TRANSFERS.csv.gz)","")
	@echo "Unable to find $(datadir)TRANSFERS.csv.gz. Exiting before build."; exit1
endif
	@echo 'All data present!'
	@echo ''

.PHONY: help mimic
