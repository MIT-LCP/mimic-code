## ------------------------------------------------------------------
## Title: Build file for etc and etc/firstday
## Description: Automated import of SQL scripts for etc and etc/firstday
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
	@echo 'extra: Miscellaneous staging scripts for useful clinical concepts'
	@echo '  firstday: Miscellaneous scripts for concepts on day 1 of an admission'

extra: firstday echo-data rrt ventilation-durations

firstday:
	@$(MAKE) -e -C firstday extra

clean:
	@$(PSQL) -f clean.sql
	@$(MAKE) -e -C firstday clean

.PHONY: extra firstday help clean


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<

