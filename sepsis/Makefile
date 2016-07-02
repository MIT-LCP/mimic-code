## ------------------------------------------------------------------
## Title: Build file for sepsis
## Description: Automated import of SQL scripts for sepsis
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

sepsis: angus

.PHONY: sepsis


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<


