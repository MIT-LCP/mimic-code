## ------------------------------------------------------------------
## Title: Build file for severityscores
## Description: Automated import of SQL scripts for severityscores
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
	@echo 'severityscores: Severity scores'
	@echo 'clean: Drop all severity score materialized views'

extra: apsiii lods mlods oasis qsofa sapsii saps sirs sofa

clean:
	@$(PSQL) -f clean.sql

.PHONY: extra help clean


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<
