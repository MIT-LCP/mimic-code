-- ------------------------------------------------------------------  
-- Title: SQL clean script called by "make clean"
-- Description: Drops all materialized views re: first day concepts
-- MIMIC version: All
-- Author: Jim Blundell 2016
-- ------------------------------------------------------------------  

DROP MATERIALIZED VIEW IF EXISTS bloodgasfirstdayarterial CASCADE;
DROP MATERIALIZED VIEW IF EXISTS bloodgasfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS gcsfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS labsfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS rrtfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS uofirstday CASCADE;
DROP TABLE IF EXISTS ventfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS vitalsfirstday CASCADE;
