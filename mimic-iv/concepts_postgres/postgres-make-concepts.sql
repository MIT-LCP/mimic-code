\echo ''
\echo '==='
\echo 'Beginning to create materialized views for MIMIC database.'
\echo 'Any notices of the form  "NOTICE: materialized view "XXXXXX" does not exist" can be ignored.'
\echo 'The scripts drop views before creating them, and these notices indicate nothing existed prior to creating the view.'
\echo '==='
\echo ''

-- Set the search_path, i.e. the location at which we generate tables.
-- postgres looks at schemas sequentially, so this will generate tables on the mimiciv_derived schema

-- NOTE: many scripts *require* you to use mimiciv_derived as the schema for outputting concepts
-- change the search path at your peril!
SET search_path TO mimiciv_derived, mimiciv_hosp, mimiciv_icu, mimiciv_ed;

-- dependencies
\i demographics/icustay_times.sql
\i demographics/icustay_hourly.sql
\i demographics/weight_durations.sql
\i measurement/urine_output.sql
\i organfailure/kdigo_uo.sql

-- demographics
\i demographics/age.sql
\i demographics/icustay_detail.sql

-- measurement
\i measurement/bg.sql
\i measurement/blood_differential.sql
\i measurement/cardiac_marker.sql
\i measurement/chemistry.sql
\i measurement/coagulation.sql
\i measurement/complete_blood_count.sql
\i measurement/creatinine_baseline.sql
\i measurement/enzyme.sql
\i measurement/gcs.sql
\i measurement/height.sql
\i measurement/icp.sql
\i measurement/inflammation.sql
\i measurement/oxygen_delivery.sql
\i measurement/rhythm.sql
\i measurement/urine_output_rate.sql
\i measurement/ventilator_setting.sql
\i measurement/vitalsign.sql

-- comorbidity
\i comorbidity/charlson.sql

-- medication
\i medication/acei.sql
\i medication/antibiotic.sql
\i medication/dobutamine.sql
\i medication/dopamine.sql
\i medication/epinephrine.sql
\i medication/milrinone.sql
\i medication/neuroblock.sql
\i medication/norepinephrine.sql
\i medication/nsaid.sql
\i medication/phenylephrine.sql
\i medication/vasopressin.sql

-- treatment
\i treatment/crrt.sql
\i treatment/invasive_line.sql
\i treatment/rrt.sql
\i treatment/ventilation.sql

-- firstday
\i firstday/first_day_bg.sql
\i firstday/first_day_bg_art.sql
\i firstday/first_day_gcs.sql
\i firstday/first_day_height.sql
\i firstday/first_day_lab.sql
\i firstday/first_day_rrt.sql
\i firstday/first_day_urine_output.sql
\i firstday/first_day_vitalsign.sql
\i firstday/first_day_weight.sql

-- organfailure
\i organfailure/kdigo_creatinine.sql
\i organfailure/meld.sql

-- score
\i score/apsiii.sql
\i score/lods.sql
\i score/oasis.sql
\i score/sapsii.sql
\i score/sirs.sql
\i score/sofa.sql

-- sepsis
\i sepsis/suspicion_of_infection.sql

-- final tables which were dependent on one or more prior tables
\i organfailure/kdigo_stages.sql
\i firstday/first_day_sofa.sql
\i sepsis/sepsis3.sql
\i medication/vasoactive_agent.sql
\i medication/norepinephrine_equivalent_dose.sql
