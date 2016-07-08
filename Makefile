## ------------------------------------------------------------------
## Title: Top-level build file
## Description: Automated import of data and SQL scripts
## MIMIC version: MIMIC-III v1.3
## Author: Jim Blundell 2016
## ------------------------------------------------------------------

## Parameters ##

DBNAME=mimic
DBUSER=mimic
SCHEMA=mimiciii
DATADIR=


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
	@echo 'mimic: Import data'
	@echo 'extra: Create community contributed materialzed views'
	@echo '                                                                           '
	@echo 'extra includes:'
	@echo '  etc: Miscellaneous staging scripts for useful clinical concepts'
	@echo '    firstday: Miscellaneous scripts for concepts on day 1 of an admission'
	@echo '  comorbidity: Comorbidity scores'
	@echo '  sepsis: Sepsis scores'
	@echo '  severityscores: Severity scores'
	@echo '                                                                           '
	@echo '---------------------------------------------------------------------------'
	@echo '   Build MIMIC-III using the CSV files in the /path/to/data directory -    '
	@echo '                                                                           '
	@echo '             make mimic DATADIR="/path/to/data/"                           '
	@echo '                                                                           '
	@echo '             e.g. make mimic DATADIR="/data/mimic/v1_3/"                   '
	@echo '                                                                            '
	@echo '   Build MIMIC-III using the .csv.gz files in the /path/to/data directory - '
	@echo '                                                                            '
	@echo '             make mimic-gz datadir="/path/to/data/"                         '
	@echo '                                                                            '
	@echo '             e.g. make mimic-gz datadir="/data/mimic/v1_3/"                 '
	@echo '---------------------------------------------------------------------------'

mimic: mimic-build mimic-check
mimic-gz: mimic-build-gz mimic-check-gz

mimic-build:
	@$(MAKE) -e -C buildmimic/postgres mimic-build

mimic-check:
	@$(MAKE) -e -C buildmimic/postgres mimic-check

mimic-build-gz:
	@$(MAKE) -e -C buildmimic/postgres mimic-build-gz

mimic-check-gz:
	@$(MAKE) -e -C buildmimic/postgres mimic-check-gz

extra: comorbidity demographics sepsis severityscores


## Individual build targets ##

etc:
	@$(MAKE) -e -C etc etc

comorbidity: etc
	@$(MAKE) -e -C comorbidity/postgres comorbidity

demographics: etc
	@$(MAKE) -e -C demographics/postgres demographics

sepsis: etc
	@$(MAKE) -e -C sepsis sepsis

severityscores: etc
	@$(MAKE) -e -C severityscores severityscores

## Clean ##

clean:
	@$(MAKE) -e -C buildmimic/postgres clean
	@$(MAKE) -e -C etc clean
	@$(MAKE) -e -C comorbidity clean
	@$(MAKE) -e -C demographics clean
	@$(MAKE) -e -C sepsis clean
	@$(MAKE) -e -C severityscores clean

.PHONY: help mimic mimic-build mimic-check mimic-gz mimic-build-gz mimic-check-gz extra etc comorbidity demographics sepsis severityscores

