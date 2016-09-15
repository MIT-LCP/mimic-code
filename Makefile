## ------------------------------------------------------------------
## Title: Top-level build file
## Description: Automated import of data and SQL scripts
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
	@echo '                                                                            '
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

extra: comorbidity demographics sepsis severityscores


## Individual build targets ##

etc:
	@$(MAKE) -e -C etc extra

comorbidity: etc
	@$(MAKE) -e -C comorbidity/postgres extra

demographics: etc
	@$(MAKE) -e -C demographics/postgres extra

sepsis: etc
	@$(MAKE) -e -C sepsis extra

severityscores: etc
	@$(MAKE) -e -C severityscores extra

## Clean ##

clean:
	@$(MAKE) -e -C buildmimic/postgres clean
	@$(MAKE) -e -C etc clean
	@$(MAKE) -e -C comorbidity/postgres clean
	@$(MAKE) -e -C demographics/postgres clean
	@$(MAKE) -e -C sepsis clean
	@$(MAKE) -e -C severityscores clean

.PHONY: help mimic mimic-build mimic-download mimic-check mimic-gz mimic-build-gz mimic-check-gz extra etc comorbidity demographics sepsis severityscores
