-- ------------------------------------------------------------------
-- Title: SQL clean script called by "make clean"
-- Description: Drops all materialized views re: misc clinical concepts
-- ------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS ECHODATA CASCADE;
DROP MATERIALIZED VIEW IF EXISTS rrt CASCADE;
-- Tables for ventdurations
DROP TABLE IF EXISTS ventsettings CASCADE;
DROP TABLE IF EXISTS ventdurations CASCADE;
