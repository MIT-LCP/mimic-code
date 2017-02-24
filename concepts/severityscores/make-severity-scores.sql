-- This function runs all the scripts necessary to generate the following severity scores:
--  OASIS
--  SAPS
--  SAPS II
--  APS III
--  SOFA

-- As the script is generating many materialized views, it may take some time.
-- Note: you should run this script from the 'severityscores' subfolder, as it makes use of relative pathnames.

BEGIN;
-- ----------------------------- --
-- ---------- STAGE 1 ---------- --
-- ----------------------------- --

-- Generate the views which the severity scores are based on
\i ../firstday/urine-output-first-day.sql
\i ../firstday/vitals-first-day.sql
\i ../firstday/gcs-first-day.sql
\i ../firstday/labs-first-day.sql
\i ../firstday/blood-gas-first-day.sql
\i ../firstday/blood-gas-first-day-arterial.sql
\i ../echo-data.sql
\i ../ventilation-durations.sql
-- note vent first day relies on vent durations
\i ../firstday/ventilation-first-day.sql

-- ----------------------------- --
-- ---------- STAGE 2 ---------- --
-- ----------------------------- --

-- Generate the severity of illness scores
\i oasis.sql
\i sofa.sql
\i saps.sql
\i sapsii.sql
\i apsiii.sql
\i lods.sql

COMMIT;
