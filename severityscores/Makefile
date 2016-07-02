## ------------------------------------------------------------------
## Title: Build file for severityscores
## Description: Automated import of SQL scripts for severityscores
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

severityscores: apsiii oasis sapsii saps sofa

.PHONY: severityscores


## Implicit rules ##

%: %.sql
	@echo
	@echo '--- Building' $< '---'
	@echo
	@$(PSQL) -f $<

