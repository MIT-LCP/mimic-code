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
\i ../etc/firstday/urine-output-first-day.sql
\i ../etc/firstday/ventilation-first-day.sql
\i ../etc/firstday/vitals-first-day.sql
\i ../etc/firstday/gcs-first-day.sql
\i ../etc/firstday/labs-first-day.sql
\i ../etc/firstday/blood-gas-first-day.sql
\i ../etc/firstday/blood-gas-first-day-arterial.sql
\i ../etc/echo-data.sql
\i ../etc/ventilation-durations.sql

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
