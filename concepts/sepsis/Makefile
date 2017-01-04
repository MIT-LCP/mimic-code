## ------------------------------------------------------------------
## Title: Build file for sepsis
## Description: Automated import of SQL scripts for sepsis
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
	@echo 'extra: Sepsis scores'
	@echo '  angus: Angus sepsis score'
	@echo 'clean: Remove all sepsis score materialized views'

extra: angus

clean:
	@$(PSQL) -f clean.sql

.PHONY: help sepsis clean


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<
