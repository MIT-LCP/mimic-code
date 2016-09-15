-- ------------------------------------------------------------------
-- Title: SQL clean script called by "make clean"
-- Description: Drops all materialized views re: demographics
-- ------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS icustay_detail CASCADE;
DROP MATERIALIZED VIEW IF EXISTS heightweight CASCADE;
