-- this query runs a few simple checks to make sure the database has loaded in OK
-- These checks are designed for MIMIC-III v1.4

-- If running scripts individually, you can set the schema where all tables are created as follows:
-- SET search_path TO mimiciii;

with expected as
(
  -- buildmimic
  select 'admissions' as tbl, 26836 as row_count UNION ALL
  select 'callout' as tbl, 6480 as row_count UNION ALL
  select 'caregivers' as tbl, 7567 as row_count UNION ALL
  select 'chartevents' as tbl, 172484058 as row_count UNION ALL
  select 'cptevents' as tbl, 172213 as row_count UNION ALL
  select 'd_cpt' as tbl, 134 as row_count UNION ALL
  select 'd_icd_diagnoses' as tbl, 14567 as row_count UNION ALL
  select 'd_icd_procedures' as tbl, 3882 as row_count UNION ALL
  select 'd_items' as tbl, 12487 as row_count UNION ALL
  select 'd_labitems' as tbl, 753 as row_count UNION ALL
  select 'datetimeevents' as tbl, 1222856 as row_count UNION ALL
  select 'diagnoses_icd' as tbl, 225345 as row_count UNION ALL
  select 'drgcodes' as tbl, 38919 as row_count UNION ALL
  select 'icustays' as tbl, 28391 as row_count UNION ALL
  select 'inputevents_cv' as tbl, 13560330 as row_count UNION ALL
  select 'labevents' as tbl, 10896310 as row_count UNION ALL
  select 'microbiologyevents' as tbl, 281248 as row_count UNION ALL
  select 'noteevents' as tbl, 880107 as row_count UNION ALL
  select 'outputevents' as tbl, 2021183 as row_count UNION ALL
  select 'patients' as tbl, 23692 as row_count UNION ALL
  select 'prescriptions' as tbl, 1435643 as row_count UNION ALL
  select 'procedures_icd' as tbl, 113012 as row_count UNION ALL
  select 'services' as tbl, 32207 as row_count UNION ALL
  select 'transfers' as tbl, 118217 as row_count UNION ALL
  -- concepts
  select 'code_status' as tbl, 28391 as row_count UNION ALL
  select 'ventilation_classification' as tbl, 1388864 as row_count UNION ALL
  select 'ventilation_durations' as tbl, 18454 as row_count UNION ALL
  select 'crrt_durations' as tbl, 2796 as row_count UNION ALL
  select 'dobutamine_durations' as tbl, 904 as row_count UNION ALL
  select 'dopamine_durations' as tbl, 3420 as row_count UNION ALL
  select 'epinephrine_durations' as tbl, 907 as row_count UNION ALL
  select 'isuprel_durations' as tbl, 2 as row_count UNION ALL
  select 'milrinone_durations' as tbl, 845 as row_count UNION ALL
  select 'norepinephrine_durations' as tbl, 7092 as row_count UNION ALL
  select 'phenylephrine_durations' as tbl, 11512 as row_count UNION ALL
  select 'vasopressin_durations' as tbl, 1597 as row_count UNION ALL
  select 'vasopressor_durations' as tbl, 18304 as row_count UNION ALL
  select 'weight_durations' as tbl, 924615 as row_count UNION ALL
  select 'elixhauser_ahrq_v37' as tbl, 26836 as row_count UNION ALL
  select 'elixhauser_ahrq_v37_no_drg' as tbl, 26836 as row_count UNION ALL
  select 'elixhauser_quan' as tbl, 26836 as row_count UNION ALL
  select 'elixhauser_score_ahrq' as tbl, 26836 as row_count UNION ALL
  select 'elixhauser_score_quan' as tbl, 26836 as row_count UNION ALL
  select 'icustay_detail' as tbl, 28121 as row_count UNION ALL
  select 'blood_gas_first_day' as tbl, 112259 as row_count UNION ALL
  select 'blood_gas_first_day_arterial' as tbl, 79579 as row_count UNION ALL
  select 'gcs_first_day' as tbl, 28391 as row_count UNION ALL
  select 'height_first_day' as tbl, 20291 as row_count UNION ALL
  select 'labs_first_day' as tbl, 28391 as row_count UNION ALL
  select 'rrt_first_day' as tbl, 28391 as row_count UNION ALL
  select 'urine_output_first_day' as tbl, 22084 as row_count UNION ALL
  select 'ventilation_first_day' as tbl, 28391 as row_count UNION ALL
  select 'vitals_first_day' as tbl, 5728 as row_count UNION ALL
  select 'weight_first_day' as tbl, 20291 as row_count UNION ALL
  select 'urine_output' as tbl, 1539085 as row_count UNION ALL
  select 'angus' as tbl, 26836 as row_count UNION ALL
  select 'martin' as tbl, 26836 as row_count UNION ALL
  select 'explicit' as tbl, 26836 as row_count UNION ALL
  select 'ccs_dx' as tbl, 15072 as row_count UNION ALL
  select 'kdigo_creatinine' as tbl, 152444 as row_count UNION ALL
  select 'kdigo_uo' as tbl, 1539085 as row_count UNION ALL
  select 'kdigo_stages' as tbl, 1683340 as row_count UNION ALL
  select 'kdigo_stages_7day' as tbl, 28391 as row_count UNION ALL
  select 'kdigo_stages_48hr' as tbl, 28391 as row_count UNION ALL
  select 'meld' as tbl, 28391 as row_count UNION ALL
  select 'oasis' as tbl, 28391 as row_count UNION ALL
  select 'sofa' as tbl, 28391 as row_count UNION ALL
  select 'saps' as tbl, 28391 as row_count UNION ALL
  select 'sapsii' as tbl, 28391 as row_count UNION ALL
  select 'apsiii' as tbl, 28391 as row_count UNION ALL
  select 'lods' as tbl, 28391 as row_count UNION ALL
  select 'sirs' as tbl, 28391 as row_count UNION ALL
  select 'qsofa' as tbl, 28391 as row_count UNION ALL
  select 'sepsis3' as tbl, 28391 as row_count UNION ALL
  select 'age' as tbl, 26836 as row_count UNION ALL
  select 'charlson' as tbl, 26836 as row_count
)

, observed as
(
  -- buildmimic
  select 'admissions' as tbl, count(*) as row_count from admissions UNION ALL
  select 'callout' as tbl, count(*) as row_count from callout UNION ALL
  select 'caregivers' as tbl, count(*) as row_count from caregivers UNION ALL
  select 'chartevents' as tbl, count(*) as row_count from chartevents UNION ALL
  select 'cptevents' as tbl, count(*) as row_count from cptevents UNION ALL
  select 'd_cpt' as tbl, count(*) as row_count from d_cpt UNION ALL
  select 'd_icd_diagnoses' as tbl, count(*) as row_count from d_icd_diagnoses UNION ALL
  select 'd_icd_procedures' as tbl, count(*) as row_count from d_icd_procedures UNION ALL
  select 'd_items' as tbl, count(*) as row_count from d_items UNION ALL
  select 'd_labitems' as tbl, count(*) as row_count from d_labitems UNION ALL
  select 'datetimeevents' as tbl, count(*) as row_count from datetimeevents UNION ALL
  select 'diagnoses_icd' as tbl, count(*) as row_count from diagnoses_icd UNION ALL
  select 'drgcodes' as tbl, count(*) as row_count from drgcodes UNION ALL
  select 'icustays' as tbl, count(*) as row_count from icustays UNION ALL
  select 'inputevents_cv' as tbl, count(*) as row_count from inputevents_cv UNION ALL
  select 'labevents' as tbl, count(*) as row_count from labevents UNION ALL
  select 'microbiologyevents' as tbl, count(*) as row_count from microbiologyevents UNION ALL
  select 'noteevents' as tbl, count(*) as row_count from noteevents UNION ALL
  select 'outputevents' as tbl, count(*) as row_count from outputevents UNION ALL
  select 'patients' as tbl, count(*) as row_count from patients UNION ALL
  select 'prescriptions' as tbl, count(*) as row_count from prescriptions UNION ALL
  select 'procedures_icd' as tbl, count(*) as row_count from procedures_icd UNION ALL
  select 'services' as tbl, count(*) as row_count from services UNION ALL
  select 'transfers' as tbl, count(*) as row_count from transfers UNION ALL
  -- concepts
  select 'code_status' as tbl, count(*) as row_count from code_status UNION ALL
  select 'ventilation_classification' as tbl, count(*) as row_count from ventilation_classification UNION ALL
  select 'ventilation_durations' as tbl, count(*) as row_count from ventilation_durations UNION ALL
  select 'crrt_durations' as tbl, count(*) as row_count from crrt_durations UNION ALL
  select 'dobutamine_durations' as tbl, count(*) as row_count from dobutamine_durations UNION ALL
  select 'dopamine_durations' as tbl, count(*) as row_count from dopamine_durations UNION ALL
  select 'epinephrine_durations' as tbl, count(*) as row_count from epinephrine_durations UNION ALL
  select 'isuprel_durations' as tbl, count(*) as row_count from isuprel_durations UNION ALL
  select 'milrinone_durations' as tbl, count(*) as row_count from milrinone_durations UNION ALL
  select 'norepinephrine_durations' as tbl, count(*) as row_count from norepinephrine_durations UNION ALL
  select 'phenylephrine_durations' as tbl, count(*) as row_count from phenylephrine_durations UNION ALL
  select 'vasopressin_durations' as tbl, count(*) as row_count from vasopressin_durations UNION ALL
  select 'vasopressor_durations' as tbl, count(*) as row_count from vasopressor_durations UNION ALL
  select 'weight_durations' as tbl, count(*) as row_count from weight_durations UNION ALL
  select 'elixhauser_ahrq_v37' as tbl, count(*) as row_count from elixhauser_ahrq_v37 UNION ALL
  select 'elixhauser_ahrq_v37_no_drg' as tbl, count(*) as row_count from elixhauser_ahrq_v37_no_drg UNION ALL
  select 'elixhauser_quan' as tbl, count(*) as row_count from elixhauser_quan UNION ALL
  select 'elixhauser_score_ahrq' as tbl, count(*) as row_count from elixhauser_score_ahrq UNION ALL
  select 'elixhauser_score_quan' as tbl, count(*) as row_count from elixhauser_score_quan UNION ALL
  select 'icustay_detail' as tbl, count(*) as row_count from icustay_detail UNION ALL
  select 'blood_gas_first_day' as tbl, count(*) as row_count from blood_gas_first_day UNION ALL
  select 'blood_gas_first_day_arterial' as tbl, count(*) as row_count from blood_gas_first_day_arterial UNION ALL
  select 'gcs_first_day' as tbl, count(*) as row_count from gcs_first_day UNION ALL
  select 'height_first_day' as tbl, count(*) as row_count from height_first_day UNION ALL
  select 'labs_first_day' as tbl, count(*) as row_count from labs_first_day UNION ALL
  select 'rrt_first_day' as tbl, count(*) as row_count from rrt_first_day UNION ALL
  select 'urine_output_first_day' as tbl, count(*) as row_count from urine_output_first_day UNION ALL
  select 'ventilation_first_day' as tbl, count(*) as row_count from ventilation_first_day UNION ALL
  select 'vitals_first_day' as tbl, count(*) as row_count from vitals_first_day UNION ALL
  select 'weight_first_day' as tbl, count(*) as row_count from weight_first_day UNION ALL
  select 'urine_output' as tbl, count(*) as row_count from urine_output UNION ALL
  select 'angus' as tbl, count(*) as row_count from angus UNION ALL
  select 'martin' as tbl, count(*) as row_count from martin UNION ALL
  select 'explicit' as tbl, count(*) as row_count from explicit UNION ALL
  select 'ccs_dx' as tbl, count(*) as row_count from ccs_dx UNION ALL
  select 'kdigo_creatinine' as tbl, count(*) as row_count from kdigo_creatinine UNION ALL
  select 'kdigo_uo' as tbl, count(*) as row_count from kdigo_uo UNION ALL
  select 'kdigo_stages' as tbl, count(*) as row_count from kdigo_stages UNION ALL
  select 'kdigo_stages_7day' as tbl, count(*) as row_count from kdigo_stages_7day UNION ALL
  select 'kdigo_stages_48hr' as tbl, count(*) as row_count from kdigo_stages_48hr UNION ALL
  select 'meld' as tbl, count(*) as row_count from meld UNION ALL
  select 'oasis' as tbl, count(*) as row_count from oasis UNION ALL
  select 'sofa' as tbl, count(*) as row_count from sofa UNION ALL
  select 'saps' as tbl, count(*) as row_count from saps UNION ALL
  select 'sapsii' as tbl, count(*) as row_count from sapsii UNION ALL
  select 'apsiii' as tbl, count(*) as row_count from apsiii UNION ALL
  select 'lods' as tbl, count(*) as row_count from lods UNION ALL
  select 'sirs' as tbl, count(*) as row_count from sirs UNION ALL
  select 'qsofa' as tbl, count(*) as row_count from qsofa UNION ALL
  select 'sepsis3' as tbl, count(*) as row_count from sepsis3 UNION ALL
  select 'age' as tbl, count(*) as row_count from age UNION ALL
  select 'charlson' as tbl, count(*) as row_count from charlson
)

select
  exp.tbl
  , exp.row_count as expected_count
  , obs.row_count as observed_count
  , case
      when exp.row_count = obs.row_count
        then 'PASSED'
      else 'FAILED'
    end as ROW_COUNT_CHECK
from expected exp
inner join observed obs
  on exp.tbl = obs.tbl
order by exp.tbl;
