-- This file makes all materialized views in this subfolder
-- Note that this may take a large amount of time and hard drive space

\echo 'Beginning to create materialized views for MIMIC database.'

\echo 'Top level files..'
\i code-status.sql
\i echo-data.sql

-- Durations (usually of treatments)
\echo 'Directory 1 of 7: durations'
\i durations/ventilation-durations.sql
\i durations/crrt-durations.sql
\i durations/adenosine-durations.sql
\i durations/dobutamine-durations.sql
\i durations/dopamine-durations.sql
\i durations/epinephrine-durations.sql
\i durations/isuprel-durations.sql
\i durations/milrinone-durations.sql
\i durations/norepinephrine-durations.sql
\i durations/phenylephrine-durations.sql
\i durations/vasopressin-durations.sql
\i durations/vasopressor-durations.sql

\echo 'Directory 2 of 7: comorbidity'
\i comorbidity/elixhauser-ahrq-v37-with-drg.sql
\i comorbidity/elixhauser-quan.sql
\i comorbidity/elixhauser-score-ahrq.sql
\i comorbidity/elixhauser-score-quan.sql

\echo 'Directory 3 of 7: demographics'
\i demographics/HeightWeightQuery.sql
\i demographics/icustay_detail.sql

\echo 'Directory 4 of 7: firstday'
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

\echo 'Directory 5 of 7: sepsis'
\i sepsis/angus.sql

-- diagnosis mapping using CCS
\echo 'Directory 6 of 7: diagnosis'
\cd diagnosis
\i ccs_diagnosis_table.sql
\cd ..

-- Severity of illness scores (requires many views from above)
\echo 'Directory 7 of 7: severityscores'
\i severityscores/oasis.sql
\i severityscores/sofa.sql
\i severityscores/saps.sql
\i severityscores/sapsii.sql
\i severityscores/apsiii.sql
\i severityscores/lods.sql

\echo 'Finished loading materialized views.'
