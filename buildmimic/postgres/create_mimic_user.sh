#!/bin/bash

sudo -u postgres psql > /dev/null <<- EOSQL
                CREATE USER MIMIC WITH PASSWORD '$MIMIC_PASSWORD';
                CREATE DATABASE MIMIC OWNER MIMIC;
EOSQL
