## ------------------------------------------------------------------  
## Title: Build file for etc/firstday
## Description: Automated import of SQL scripts for firstday
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

#blood-gas-first-day-arterial: blood-gas-first-day
extra: blood-gas-first-day blood-gas-first-day-arterial gcs-first-day lab-first-day rrt-first-day urine-output-first-day ventilation-first-day vitals-first-day

clean:
	@$(PSQL) -f clean.sql

.PHONY: extra clean


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<

