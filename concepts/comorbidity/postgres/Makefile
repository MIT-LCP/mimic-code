## ------------------------------------------------------------------
## Title: Build file for comorbidity
## Description: Automated import of SQL scripts for comorbidity
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
	@echo 'extra: Comorbidity scores'
	@echo 'clean: Drop all comorbidity score materialized views'

extra: elixhauser-ahrq-v37-with-drg elixhauser-quan

clean:
	@$(PSQL) -f clean.sql

.PHONY: extra clean help


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<
