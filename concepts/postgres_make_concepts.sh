# This file makes tables for the concepts in this subfolder.
# Be sure to run postgres-functions.sql first, as the concepts rely on those function definitions.
# Note that this may take a large amount of time and hard drive space.

# string replacements are necessary for some queries
export REGEX_DATETIME_DIFF="s/DATETIME_DIFF\((.+?),\s?(.+?),\s?(DAY|MINUTE|SECOND|HOUR|YEAR)\)/DATETIME_DIFF(\1, \2, '\3')/g"
export REGEX_SCHEMA='s/`physionet-data.(mimiciii_clinical|mimiciii_derived|mimiciii_notes).(.+?)`/\2/g'
export CONNSTR='-d mimic'

# this is set as the search_path variable for psql
# a search path of "public,mimiciii" will search both public and mimiciii
# schemas for data, but will create tables on the public schema
export PSQL_PREAMBLE='SET search_path TO public,mimiciii'

echo ''
echo '==='
echo 'Beginning to create tables for MIMIC database.'
echo 'Any notices of the form "NOTICE: TABLE "XXXXXX" does not exist" can be ignored.'
echo 'The scripts drop views before creating them, and these notices indicate nothing existed prior to creating the view.'
echo '==='
echo ''

echo 'Top level files..'
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS code_status; CREATE TABLE code_status AS "; cat code_status.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS echo_data; CREATE TABLE echo_data AS "; cat echo_data.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}

# Durations (usually of treatments)
echo 'Directory 1 of 9: durations'
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ventilation_classification; CREATE TABLE ventilation_classification AS "; cat durations/ventilation_classification.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ventilation_durations; CREATE TABLE ventilation_durations AS "; cat durations/ventilation_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS crrt_durations; CREATE TABLE crrt_durations AS "; cat durations/crrt_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS adenosine_durations; CREATE TABLE adenosine_durations AS "; cat durations/adenosine_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS dobutamine_durations; CREATE TABLE dobutamine_durations AS "; cat durations/dobutamine_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS dopamine_durations; CREATE TABLE dopamine_durations AS "; cat durations/dopamine_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS epinephrine_durations; CREATE TABLE epinephrine_durations AS "; cat durations/epinephrine_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS isuprel_durations; CREATE TABLE isuprel_durations AS "; cat durations/isuprel_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS milrinone_durations; CREATE TABLE milrinone_durations AS "; cat durations/milrinone_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS norepinephrine_durations; CREATE TABLE norepinephrine_durations AS "; cat durations/norepinephrine_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS phenylephrine_durations; CREATE TABLE phenylephrine_durations AS "; cat durations/phenylephrine_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS vasopressin_durations; CREATE TABLE vasopressin_durations AS "; cat durations/vasopressin_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS vasopressor_durations; CREATE TABLE vasopressor_durations AS "; cat durations/vasopressor_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS weight_durations; CREATE TABLE weight_durations AS "; cat durations/weight_durations.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}

echo 'Directory 2 of 9: comorbidity'
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS elixhauser_ahrq_v37; CREATE TABLE elixhauser_ahrq_v37 AS "; cat comorbidity/elixhauser_ahrq_v37.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS elixhauser_ahrq_v37_no_drg; CREATE TABLE elixhauser_ahrq_v37_no_drg AS "; cat comorbidity/elixhauser_ahrq_v37_no_drg.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS elixhauser_quan; CREATE TABLE elixhauser_quan AS "; cat comorbidity/elixhauser_quan.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS elixhauser_score_ahrq; CREATE TABLE elixhauser_score_ahrq AS "; cat comorbidity/elixhauser_score_ahrq.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS elixhauser_score_quan; CREATE TABLE elixhauser_score_quan AS "; cat comorbidity/elixhauser_score_quan.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}

echo 'Directory 3 of 9: demographics'
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS icustay_detail; CREATE TABLE icustay_detail AS "; cat demographics/icustay_detail.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}

echo 'Directory 4 of 9: firstday'
# data which is extracted from a patient's first ICU stay
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS blood_gas_first_day; CREATE TABLE blood_gas_first_day AS "; cat firstday/blood_gas_first_day.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS blood_gas_first_day_arterial; CREATE TABLE blood_gas_first_day_arterial AS "; cat firstday/blood_gas_first_day_arterial.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS gcs_first_day; CREATE TABLE gcs_first_day AS "; cat firstday/gcs_first_day.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS height_first_day; CREATE TABLE height_first_day AS "; cat firstday/height_first_day.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS labs_first_day; CREATE TABLE labs_first_day AS "; cat firstday/labs_first_day.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS rrt_first_day; CREATE TABLE rrt_first_day AS "; cat firstday/rrt_first_day.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS urine_output_first_day; CREATE TABLE urine_output_first_day AS "; cat firstday/urine_output_first_day.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS ventilation_first_day; CREATE TABLE ventilation_first_day AS "; cat firstday/ventilation_first_day.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS vitals_first_day; CREATE TABLE vitals_first_day AS "; cat firstday/vitals_first_day.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS weight_first_day; CREATE TABLE weight_first_day AS "; cat firstday/weight_first_day.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}

echo 'Directory 5 of 9: fluid_balance'
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS urine_output; CREATE TABLE urine_output AS "; cat fluid_balance/urine_output.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}

echo 'Directory 6 of 9: sepsis'
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS angus; CREATE TABLE angus AS "; cat sepsis/angus.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS martin; CREATE TABLE martin AS "; cat sepsis/martin.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS explicit; CREATE TABLE explicit AS "; cat sepsis/explicit.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}

# diagnosis mapping using CCS
echo 'Directory 7 of 9: diagnosis'
cd diagnosis
psql ${CONNSTR} -f ccs_diagnosis_table_psql.sql
cd ..

# Organ failure scores
echo 'Directory 8 of 9: organfailure'
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS kdigo_creatinine; CREATE TABLE kdigo_creatinine AS "; cat organfailure/kdigo_creatinine.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS kdigo_uo; CREATE TABLE kdigo_uo AS "; cat organfailure/kdigo_uo.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS kdigo_stages; CREATE TABLE kdigo_stages AS "; cat organfailure/kdigo_stages.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS kdigo_stages_7day; CREATE TABLE kdigo_stages_7day AS "; cat organfailure/kdigo_stages_7day.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS kdigo_stages_48hr; CREATE TABLE kdigo_stages_48hr AS "; cat organfailure/kdigo_stages_48hr.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS meld; CREATE TABLE meld AS "; cat organfailure/meld.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}

# Severity of illness scores (requires many views from above)
echo 'Directory 9 of 9: severityscores'
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS oasis; CREATE TABLE oasis AS "; cat severityscores/oasis.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS sofa; CREATE TABLE sofa AS "; cat severityscores/sofa.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS saps; CREATE TABLE saps AS "; cat severityscores/saps.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS sapsii; CREATE TABLE sapsii AS "; cat severityscores/sapsii.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS apsiii; CREATE TABLE apsiii AS "; cat severityscores/apsiii.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS lods; CREATE TABLE lods AS "; cat severityscores/lods.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}
{ echo "${PSQL_PREAMBLE}; DROP TABLE IF EXISTS sirs; CREATE TABLE sirs AS "; cat severityscores/sirs.sql; } | sed -r -e "${REGEX_DATETIME_DIFF}" | sed -r -e "${REGEX_SCHEMA}" | psql ${CONNSTR}

echo 'Finished creating tables.'
