## ------------------------------------------------------------------
## Title: Build file for etc/firstday
## Description: Automated import of SQL scripts for firstday
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

#blood-gas-first-day-arterial: blood-gas-first-day
extra: blood-gas-first-day blood-gas-first-day-arterial gcs-first-day height-first-day lab-first-day rrt-first-day urine-output-first-day ventilation-first-day vitals-first-day weight-first-day

clean:
	@$(PSQL) -f clean.sql

.PHONY: extra clean


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<
