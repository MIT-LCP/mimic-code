-- ------------------------------------------------------------------
-- Title: SQL clean script called by "make clean"
-- Description: Drops all materialized views re: first day concepts
-- ------------------------------------------------------------------

DROP MATERIALIZED VIEW IF EXISTS bloodgasfirstdayarterial CASCADE;
DROP MATERIALIZED VIEW IF EXISTS bloodgasfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS gcsfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS heightfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS labsfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS rrtfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS uofirstday CASCADE;
-- Need to drop table as well for legacy purposes
DROP TABLE IF EXISTS ventfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS ventfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS vitalsfirstday CASCADE;
DROP MATERIALIZED VIEW IF EXISTS weightfirstday CASCADE;
