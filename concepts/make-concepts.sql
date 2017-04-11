-- This file makes all materialized views in this subfolder
-- Note that this may take a large amount of time and hard drive space

\echo 'Beginning to create materialized views for MIMIC database.'
BEGIN;
\echo 'Top level files..'
\i code-status.sql
\i echo-data.sql
\i ventilation-durations.sql

\echo 'Directory 1 of 6: comorbidity'
\i comorbidity/elixhauser-ahrq-v37-with-drg.sql
\i comorbidity/elixhauser-quan.sql
\i comorbidity/elixhauser-score-ahrq.sql
\i comorbidity/elixhauser-score-quan.sql

\echo 'Directory 2 of 6: demographics'
\i demographics/HeightWeightQuery.sql
\i demographics/icustay_detail.sql

\echo 'Directory 3 of 6: firstday'
-- data which is extracted from a patient's first ICU stay
\i firstday/blood-gas-first-day.sql
\i firstday/blood-gas-first-day-arterial.sql
\i firstday/gcs-first-day.sql
\i firstday/height-first-day.sql
\i firstday/labs-first-day.sql
\i firstday/rrt-first-day.sql
\i firstday/urine-output-first-day.sql
\i firstday/ventilation-first-day.sql
\i firstday/vitals-first-day.sql
\i firstday/weight-first-day.sql

\echo 'Directory 4 of 6: sepsis'
\i sepsis/angus.sql

-- vasopressor durations
\echo 'Directory 5 of 6: vasopressor-durations'
\i vasopressor-durations/adenosine-durations.sql
\i vasopressor-durations/dobutamine-durations.sql
\i vasopressor-durations/dopamine-durations.sql
\i vasopressor-durations/epinephrine-durations.sql
\i vasopressor-durations/isuprel-durations.sql
\i vasopressor-durations/milrinone-durations.sql
\i vasopressor-durations/norepinephrine-durations.sql
\i vasopressor-durations/phenylephrine-durations.sql
\i vasopressor-durations/vasopressin-durations.sql
\i vasopressor-durations/vasopressor-durations.sql

-- Severity of illness scores (requires many views from above)
\echo 'Directory 6 of 6: severityscores'
\i severityscores/oasis.sql
\i severityscores/sofa.sql
\i severityscores/saps.sql
\i severityscores/sapsii.sql
\i severityscores/apsiii.sql
\i severityscores/lods.sql

COMMIT;
\echo 'Finished loading materialized views.'
