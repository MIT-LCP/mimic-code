## ------------------------------------------------------------------
## Title: Build file for demographics
## Description: Automated import of SQL scripts for demographics
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

extra: HeightWeightQuery icustay_detail

clean:
	@$(PSQL) -f clean.sql

.PHONY: help clean extra


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<
