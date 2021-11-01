# set the project
# gcloud config set project physionet-data

export TARGET_DATASET='mimiciii_derived'
export BQ_FLAGS='--use_legacy_sql=False --replace'

echo ''
echo '==='
echo 'Beginning to create concepts for MIMIC database.'
echo '==='
echo ''

# echo the commands called
set -x

echo 'Top level files..'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.code_status < code_status.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.echo_data < echo_data.sql

echo 'Running queries in 10 directories.'

echo 'Directory 1: demographics'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.heightweight < demographics/heightweight.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.icustay_detail < demographics/icustay_detail.sql

# Durations (usually of treatments)
echo 'Directory 2: durations'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.ventilation_classification < durations/ventilation_classification.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.ventilation_durations < durations/ventilation_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.crrt_durations < durations/crrt_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.adenosine_durations < durations/adenosine_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.dobutamine_durations < durations/dobutamine_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.dopamine_durations < durations/dopamine_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.epinephrine_durations < durations/epinephrine_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.isuprel_durations < durations/isuprel_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.milrinone_durations < durations/milrinone_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.norepinephrine_durations < durations/norepinephrine_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.phenylephrine_durations < durations/phenylephrine_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.vasopressin_durations < durations/vasopressin_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.vasopressor_durations < durations/vasopressor_durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.weight_durations < durations/weight_durations.sql
# dose queries for vasopressors
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.dobutamine_dose < durations/dobutamine_dose.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.dopamine_dose < durations/dopamine_dose.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.epinephrine_dose < durations/epinephrine_dose.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.norepinephrine_dose < durations/norepinephrine_dose.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.phenylephrine_dose < durations/phenylephrine_dose.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.vasopressin_dose < durations/vasopressin_dose.sql

# "pivoted" tables which have icustay_id / timestamp as the primary key
echo 'Directory 3: pivoted tables'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_vital < pivot/pivoted_vital.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_uo < pivot/pivoted_uo.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_rrt < pivot/pivoted_rrt.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_lab < pivot/pivoted_lab.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_invasive_lines < pivot/pivoted_invasive_lines.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_icp < pivot/pivoted_icp.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_height < pivot/pivoted_height.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_gcs < pivot/pivoted_gcs.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_fio2 < pivot/pivoted_fio2.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_bg < pivot/pivoted_bg.sql
# pivoted_bg_art must be run after pivoted_bg
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_bg_art < pivot/pivoted_bg_art.sql
# pivoted oasis depends on icustay_hours in demographics
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_oasis < pivot/pivoted_oasis.sql
# pivoted sofa depends on many above pivoted views, ventilation_durations, and dose queries
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.pivoted_sofa < pivot/pivoted_sofa.sql

echo 'Directory 4: comorbidity'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_ahrq_v37 < comorbidity/elixhauser_ahrq_v37.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_ahrq_v37_no_drg < comorbidity/elixhauser_ahrq_v37-no_drg.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_quan < comorbidity/elixhauser_quan.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_score_ahrq < comorbidity/elixhauser_score_ahrq.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_score_quan < comorbidity/elixhauser_score_quan.sql

echo 'Directory 5: firstday'
# data which is extracted from a patient's first ICU stay
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.blood_gas_first_day < firstday/blood_gas_first_day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.blood_gas_first_day_arterial < firstday/blood_gas_first_day_arterial.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.gcs_first_day < firstday/gcs_first_day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.labs_first_day < firstday/labs_first_day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.rrt_first_day < firstday/rrt_first_day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.urine_output_first_day < firstday/urine_output_first_day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.ventilation_first_day < firstday/ventilation_first_day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.vitals_first_day < firstday/vitals_first_day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.weight_first_day < firstday/weight_first_day.sql

echo 'Directory 6: fluid_balance'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.urine_output < fluid_balance/urine_output.sql

echo 'Directory 7: sepsis'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.angus < sepsis/angus.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.martin < sepsis/martin.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.explicit < sepsis/explicit.sql

# diagnosis mapping using CCS
echo 'Directory 8: diagnosis'
# load the ccs_multi_dx.csv.gz file into bq
bq load --source_format=CSV ${TARGET_DATASET}.ccs_multi_dx diagnosis/ccs_multi_dx.csv.gz diagnosis/ccs_multi_dx.json
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.ccs_dx < diagnosis/ccs_dx.sql

# Organ failure scores
echo 'Directory 9: organfailure'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_creatinine < organfailure/kdigo_creatinine.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_uo < organfailure/kdigo_uo.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_stages < organfailure/kdigo_stages.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_stages_7day < organfailure/kdigo_stages_7day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_stages_48hr < organfailure/kdigo_stages_48hr.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.meld < organfailure/meld.sql

# Severity of illness scores (requires many views from above)
echo 'Directory 10: severityscores'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.oasis < severityscores/oasis.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.sofa < severityscores/sofa.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.saps < severityscores/saps.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.sapsii < severityscores/sapsii.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.apsiii < severityscores/apsiii.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.lods < severityscores/lods.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.sirs < severityscores/sirs.sql

echo 'Finished creating concepts.'