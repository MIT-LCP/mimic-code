## ------------------------------------------------------------------
## Title: Build file for etc and etc/firstday
## Description: Automated import of SQL scripts for etc and etc/firstday
## MIMIC version: MIMIC-III v1.3
## Author: Jim Blundell 2016
## ------------------------------------------------------------------

## Parameters ##

DBNAME=mimic
DBUSER=mimic
SCHEMA=mimiciii


## Commands ##

PSQL=psql "dbname=$(DBNAME) options=--search_path=$(SCHEMA)" --username=$(DBUSER)


## Build targets ##

etc: firstday auroc echo-data rrt ventilation-durations

firstday:
	@$(MAKE) -C firstday firstday

.PHONY: etc firstday


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<

