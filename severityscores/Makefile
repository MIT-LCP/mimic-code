## ------------------------------------------------------------------
## Title: Build file for severityscores
## Description: Automated import of SQL scripts for severityscores
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
	@echo 'severityscores: Severity scores'
	@echo 'clean: Drop all severity score materialized views'

severityscores: apsiii oasis sapsii saps sofa

clean:
	@$(PSQL) -f clean.sql

.PHONY: severityscores help clean


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<

