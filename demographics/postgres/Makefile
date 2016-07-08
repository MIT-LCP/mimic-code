## ------------------------------------------------------------------
## Title: Build file for demographics
## Description: Automated import of SQL scripts for demographics
## MIMIC version: MIMIC-III v1.3
## Author: Jim Blundell 2016
## ------------------------------------------------------------------

## Parameters ##
# The top-level Makefile settings take precedence over this
DBNAME=mimic
DBUSER=mimic
SCHEMA=mimiciii


## Commands ##
# The top-level Makefile settings take precedence over this
PSQL=psql "dbname=$(DBNAME) options=--search_path=$(SCHEMA)" --username=$(DBUSER)


## Build targets ##

help:
	@echo 'demographics: tables and views related to demographics'

demographics: HeightWeightQuery icustay_detail

.PHONY: demographics


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<


