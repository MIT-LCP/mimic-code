-- ------------------------------------------------------------------  
-- Title: SQL clean script called by "make clean"
-- Description: Drops all materialized views re: misc clinical concepts
-- MIMIC version: All
-- Author: Jim Blundell 2016
-- ------------------------------------------------------------------  

DROP MATERIALIZED VIEW IF EXISTS ECHODATA CASCADE;
DROP MATERIALIZED VIEW IF EXISTS rrt CASCADE;
-- Table as well as materialized view for ventdurations
DROP TABLE IF EXISTS ventdurations CASCADE;
DROP MATERIALIZED VIEW IF EXISTS ventdurations CASCADE;
