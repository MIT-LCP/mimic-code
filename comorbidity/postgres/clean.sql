-- ------------------------------------------------------------------
-- Title: SQL clean script called by "make clean"
-- Description: Drops all materialized views re: comorbidity scoring
-- ------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS ELIXHAUSER_AHRQ CASCADE;
