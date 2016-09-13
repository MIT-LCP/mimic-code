-- ------------------------------------------------------------------  
-- Title: SQL clean script called by "make clean"
-- Description: Drops all materialized views re: sepsis
-- MIMIC version: All
-- Author: Jim Blundell 2016
-- ------------------------------------------------------------------  

DROP MATERIALIZED VIEW IF EXISTS angus_sepsis CASCADE;
