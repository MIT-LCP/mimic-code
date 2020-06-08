# set the project
# gcloud config set project bidmc-covid-19

export TARGET_DATASET='mimic_derived'
export BQ_FLAGS='--use_legacy_sql=False --replace'

echo ''
echo '==='
echo 'Beginning to create concepts for MIMIC database.'
echo '==='
echo ''

echo 'Top level files..'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.code_status < code-status.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.echo_data < echo-data.sql

# Durations (usually of treatments)
echo 'Directory 1 of 9: durations'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.ventilation_durations < durations/ventilation-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.crrt_durations < durations/crrt-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.adenosine_durations < durations/adenosine-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.dobutamine_durations < durations/dobutamine-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.dopamine_durations < durations/dopamine-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.epinephrine_durations < durations/epinephrine-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.isuprel_durations < durations/isuprel-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.milrinone_durations < durations/milrinone-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.norepinephrine_durations < durations/norepinephrine-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.phenylephrine_durations < durations/phenylephrine-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.vasopressin_durations < durations/vasopressin-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.vasopressor_durations < durations/vasopressor-durations.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.weight_durations < durations/weight-durations.sql

echo 'Directory 2 of 9: comorbidity'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_ahrq_v37_with_drg < comorbidity/elixhauser-ahrq-v37-with-drg.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_ahrq_v37_no_drg < comorbidity/elixhauser-ahrq-v37-no-drg.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_ahrq_v37_no_drg_all_icd < comorbidity/elixhauser-ahrq-v37-no-drg-all-icd.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_quan < comorbidity/elixhauser-quan.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_score_ahrq < comorbidity/elixhauser-score-ahrq.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.elixhauser_score_quan < comorbidity/elixhauser-score-quan.sql

echo 'Directory 3 of 9: demographics'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.heightweight < demographics/heightweight.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.icustay_detail < demographics/icustay-detail.sql

echo 'Directory 4 of 9: firstday'
# data which is extracted from a patient's first ICU stay
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.blood_gas_first_day < firstday/blood-gas-first-day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.blood_gas_first_day_arterial < firstday/blood-gas-first-day-arterial.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.gcs_first_day < firstday/gcs-first-day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.labs_first_day < firstday/labs-first-day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.rrt_first_day < firstday/rrt-first-day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.urine_output_first_day < firstday/urine-output-first-day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.ventilation_first_day < firstday/ventilation-first-day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.vitals_first_day < firstday/vitals-first-day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.weight_first_day < firstday/weight-first-day.sql

echo 'Directory 5 of 9: fluid-balance'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.urine_output < fluid-balance/urine-output.sql

echo 'Directory 6 of 9: sepsis'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.angus < sepsis/angus.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.martin < sepsis/martin.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.explicit < sepsis/explicit.sql

# diagnosis mapping using CCS
echo 'Directory 7 of 9: diagnosis'
#TODO: needs to load local data into bigquery
cd diagnosis
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.ccs_diagnosis_table < ccs_diagnosis_table.sql
cd ..

# Organ failure scores
echo 'Directory 8 of 9: organfailure'
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_creatinine < organfailure/kdigo-creatinine.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_uo < organfailure/kdigo-uo.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_stages_7day < organfailure/kdigo-stages-7day.sql
bq query ${BQ_FLAGS} --destination_table=${TARGET_DATASET}.kdigo_stages_48hr < organfailure/kdigo-stages-48hr.sql
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