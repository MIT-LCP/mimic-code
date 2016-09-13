-- ------------------------------------------------------------------  
-- Title: SQL clean script called by "make clean"
-- Description: Drops all materialized views re: demographics
-- MIMIC version: All
-- Author: Jim Blundell 2016
-- ------------------------------------------------------------------  

DROP MATERIALIZED VIEW IF EXISTS icustay_detail CASCADE;
DROP MATERIALIZED VIEW IF EXISTS heightweight CASCADE;

