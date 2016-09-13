-- ------------------------------------------------------------------  
-- Title: SQL clean script called by "make clean"
-- Description: Drops all materialized views re: comorbidity scoring
-- MIMIC version: All
-- Author: Jim Blundell 2016
-- ------------------------------------------------------------------  

DROP MATERIALIZED VIEW IF EXISTS ELIXHAUSER_AHRQ CASCADE;
