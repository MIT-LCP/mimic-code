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

# Durations (usually of treatments)
echo 'Directory 1 of 9: durations'
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

echo 'Directory 2 of 9: comorbidity'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_ahrq_v37_with_drg < comorbidity/elixhauser_ahrq_v37-with_drg.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_ahrq_v37_no_drg < comorbidity/elixhauser_ahrq_v37-no_drg.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_ahrq_v37_no_drg_all_icd < comorbidity/elixhauser_ahrq_v37-no_drg_all_icd.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_quan < comorbidity/elixhauser_quan.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_score_ahrq < comorbidity/elixhauser_score_ahrq.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_score_quan < comorbidity/elixhauser_score_quan.sql

echo 'Directory 3 of 9: demographics'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.heightweight < demographics/heightweight.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.icustay_detail < demographics/icustay_detail.sql

echo 'Directory 4 of 9: firstday'
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

echo 'Directory 5 of 9: fluid_balance'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.urine_output < fluid_balance/urine_output.sql

echo 'Directory 6 of 9: sepsis'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.angus < sepsis/angus.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.martin < sepsis/martin.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.explicit < sepsis/explicit.sql

# diagnosis mapping using CCS
echo 'Directory 7 of 9: diagnosis'
# load the ccs_multi_dx.csv.gz file into bq
bq load --source_format=CSV ${TARGET_DATASET}.ccs_multi_dx diagnosis/ccs_multi_dx.csv.gz diagnosis/ccs_multi_dx.json
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.ccs_dx < diagnosis/ccs_dx.sql

# Organ failure scores
echo 'Directory 8 of 9: organfailure'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_creatinine < organfailure/kdigo_creatinine.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_uo < organfailure/kdigo_uo.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_stages < organfailure/kdigo_stages.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_stages_7day < organfailure/kdigo_stages_7day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_stages_48hr < organfailure/kdigo_stages_48hr.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.meld < organfailure/meld.sql

# Severity of illness scores (requires many views from above)
echo 'Directory 9 of 9: severityscores'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.oasis < severityscores/oasis.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.sofa < severityscores/sofa.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.saps < severityscores/saps.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.sapsii < severityscores/sapsii.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.apsiii < severityscores/apsiii.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.lods < severityscores/lods.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.sirs < severityscores/sirs.sql

echo 'Finished creating concepts.'