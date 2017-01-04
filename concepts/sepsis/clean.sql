-- ------------------------------------------------------------------
-- Title: SQL clean script called by "make clean"
-- Description: Drops all materialized views re: sepsis
-- ------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS angus_sepsis CASCADE;
