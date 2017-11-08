-- This file makes all materialized views in this subfolder
-- Note that this may take a large amount of time and hard drive space

\echo ''
\echo '==='
\echo 'Beginning to create materialized views for MIMIC database.'
\echo 'Any notices of the form "NOTICE: materialized view "XXXXXX" does not exist" can be ignored.'
\echo 'The scripts drop views before creating them, and these notices indicate nothing existed prior to creating the view.'
\echo '==='
\echo ''

\echo 'Top level files..'
\i code-status.sql
\i echo-data.sql

-- Durations (usually of treatments)
\echo 'Directory 1 of 9: durations'
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
\i durations/weight-durations.sql

\echo 'Directory 2 of 9: comorbidity'
\i comorbidity/elixhauser-ahrq-v37-with-drg.sql
\i comorbidity/elixhauser-ahrq-v37-no-drg.sql
\i comorbidity/elixhauser-ahrq-v37-no-drg-all-icd.sql
\i comorbidity/elixhauser-quan.sql
\i comorbidity/elixhauser-score-ahrq.sql
\i comorbidity/elixhauser-score-quan.sql

\echo 'Directory 3 of 9: demographics'
\i demographics/HeightWeightQuery.sql
\i demographics/icustay_detail.sql

\echo 'Directory 4 of 9: firstday'
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

\echo 'Directory 5 of 9: fluid-balance'
\i fluid-balance/urine-output.sql

\echo 'Directory 6 of 9: sepsis'
\i sepsis/angus.sql
\i sepsis/martin.sql
\i sepsis/explicit.sql

-- diagnosis mapping using CCS
\echo 'Directory 7 of 9: diagnosis'
\cd diagnosis
\i ccs_diagnosis_table.sql
\cd ..

-- Organ failure scores
\echo 'Directory 8 of 9: organfailure'
\i organfailure/kdigo-creatinine.sql
\i organfailure/kdigo-uo.sql
\i organfailure/kdigo-stages-7day.sql
\i organfailure/kdigo-stages-48hr.sql
\i organfailure/meld.sql

-- Severity of illness scores (requires many views from above)
\echo 'Directory 9 of 9: severityscores'
\i severityscores/oasis.sql
\i severityscores/sofa.sql
\i severityscores/saps.sql
\i severityscores/sapsii.sql
\i severityscores/apsiii.sql
\i severityscores/lods.sql
\i severityscores/sirs.sql

\echo 'Finished loading materialized views.'
