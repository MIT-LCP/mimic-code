\echo ''
\echo '==='
\echo 'Beginning to create materialized views for MIMIC database.'
\echo 'Any notices of the form  "NOTICE: materialized view "XXXXXX" does not exist" can be ignored.'
\echo 'The scripts drop views before creating them, and these notices indicate nothing existed prior to creating the view.'
\echo '==='
\echo ''

-- dependencies
\i demographics/icustay_times.sql
\i demographics/icustay_hours.sql
\i ./echo_data.sql
\i ./code_status.sql
\i ./rrt.sql
\i durations/weight_durations.sql
\i fluid_balance/urine_output.sql
\i organfailure/kdigo_uo.sql

-- durations
\i durations/adenosine_durations.sql
\i durations/arterial_line_durations.sql
\i durations/central_line_durations.sql
\i durations/crrt_durations.sql
\i durations/dobutamine_dose.sql
\i durations/dobutamine_durations.sql
\i durations/dopamine_dose.sql
\i durations/dopamine_durations.sql
\i durations/epinephrine_dose.sql
\i durations/epinephrine_durations.sql
\i durations/isuprel_durations.sql
\i durations/milrinone_durations.sql
\i durations/neuroblock_dose.sql
\i durations/norepinephrine_dose.sql
\i durations/norepinephrine_durations.sql
\i durations/phenylephrine_dose.sql
\i durations/phenylephrine_durations.sql
\i durations/vasopressin_dose.sql
\i durations/vasopressin_durations.sql
\i durations/vasopressor_durations.sql
\i durations/ventilation_classification.sql
\i durations/ventilation_durations.sql

-- comorbidity
\i comorbidity/elixhauser_ahrq_v37.sql
\i comorbidity/elixhauser_ahrq_v37_no_drg.sql
\i comorbidity/elixhauser_quan.sql
\i comorbidity/elixhauser_score_ahrq.sql
\i comorbidity/elixhauser_score_quan.sql

-- demographics
\i demographics/heightweight.sql
\i demographics/icustay_detail.sql

-- firstday
\i firstday/blood_gas_first_day.sql
\i firstday/blood_gas_first_day_arterial.sql
\i firstday/gcs_first_day.sql
\i firstday/height_first_day.sql
\i firstday/labs_first_day.sql
\i firstday/rrt_first_day.sql
\i firstday/urine_output_first_day.sql
\i firstday/ventilation_first_day.sql
\i firstday/vitals_first_day.sql
\i firstday/weight_first_day.sql

-- fluid_balance
\i fluid_balance/colloid_bolus.sql
\i fluid_balance/crystalloid_bolus.sql
\i fluid_balance/ffp_transfusion.sql
\i fluid_balance/rbc_transfusion.sql

-- sepsis
\i sepsis/angus.sql
\i sepsis/explicit.sql
\i sepsis/martin.sql

-- diagnosis
\i diagnosis/ccs_dx.sql

-- organfailure
\i organfailure/kdigo_creatinine.sql
\i organfailure/kdigo_stages.sql
\i organfailure/kdigo_stages_48hr.sql
\i organfailure/kdigo_stages_7day.sql
\i organfailure/meld.sql

-- severityscores
\i severityscores/apsiii.sql
\i severityscores/lods.sql
\i severityscores/mlods.sql
\i severityscores/oasis.sql
\i severityscores/qsofa.sql
\i severityscores/saps.sql
\i severityscores/sapsii.sql
\i severityscores/sirs.sql
\i severityscores/sofa.sql

-- final tables which were dependent on one or more prior tables
