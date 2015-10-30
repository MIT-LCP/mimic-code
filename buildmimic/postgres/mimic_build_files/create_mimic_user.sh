#!/bin/bash

gosu postgres psql > /dev/null <<- EOSQL
                CREATE USER MIMIC WITH PASSWORD '$MIMIC_PASSWORD';
                CREATE DATABASE MIMIC OWNER MIMIC;
                \c mimic;
                CREATE SCHEMA MIMICIII;
EOSQL
