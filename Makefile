## ------------------------------------------------------------------
## Title: Top-level build file
## Description: Automated import of data and SQL scripts
## ------------------------------------------------------------------

## Parameters ##

DBNAME=mimic
DBUSER=mimic
SCHEMA=mimiciii
DATADIR=

# path of this makefile - used to locate concepts subfolder
ROOT_DIR:=$(shell "dirname" $(realpath $(lastword $(MAKEFILE_LIST))))

## Commands ##

PSQL=psql "dbname=$(DBNAME) options=--search_path=$(SCHEMA)" --username=$(DBUSER)


## Export ##
# Parameters given in this Makefile take precedence over those defined in each
# individual Makefile (due to specifying the -e option and the export command
# here)
export

## Build targets ##
help:
	@echo '---------------------------------------------------------------------------'
	@echo 'mimic-download: Download data from PhysioNet'
	@echo 'mimic-gz: Import data into a local PostgreSQL database using .csv.gz files'
	@echo 'mimic: Import data into a local PostgreSQL database using .csv files'
	@echo 'concepts: Create community contributed materialized views'
	@echo '--------------------------------------------------------------------------- '
	@echo '   Download MIMIC-III from PhysioNet to the /path/to/data/ directory -      '
	@echo '                                                                            '
	@echo '       make mimic-download physionetuser=USERNAME datadir="/path/to/data/"  '
	@echo '                                                                            '
	@echo '       e.g. make mimic-download physionetuser=me@email.com datadir="/data/" '
	@echo '                                                                            '
	@echo '   Build MIMIC-III using the CSV files in the /path/to/data directory -     '
	@echo '                                                                            '
	@echo '       make mimic datadir="/path/to/data/"                                  '
	@echo '                                                                            '
	@echo '       e.g. make mimic datadir="/data/mimic/v1_4/"                          '
	@echo '                                                                            '
	@echo '   Build MIMIC-III using the .csv.gz files in the /path/to/data directory - '
	@echo '                                                                            '
	@echo '       make mimic-gz datadir="/path/to/data/"                               '
	@echo '                                                                            '
	@echo '       e.g. make mimic-gz datadir="/data/mimic/v1_4/"                       '
	@echo '--------------------------------------------------------------------------- '

mimic: mimic-build mimic-check
mimic-gz: mimic-build-gz mimic-check-gz

mimic-download:
	@$(MAKE) -e -C buildmimic/postgres mimic-download

mimic-build:
	@$(MAKE) -e -C buildmimic/postgres mimic-build

mimic-check:
	@$(MAKE) -e -C buildmimic/postgres mimic-check

mimic-build-gz:
	@$(MAKE) -e -C buildmimic/postgres mimic-build-gz

mimic-check-gz:
	@$(MAKE) -e -C buildmimic/postgres mimic-check-gz

concepts:
	@cd $(ROOT_DIR)/concepts && $(PSQL) -f make-concepts.sql

.PHONY: help mimic mimic-build mimic-download mimic-check mimic-gz mimic-build-gz mimic-check-gz concepts
