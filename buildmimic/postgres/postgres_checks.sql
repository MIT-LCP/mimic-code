-- this query runs a few simple checks to make sure the database has loaded in OK
-- These checks are designed for MIMIC-III v1.4

-- If running scripts individually, you can set the schema where all tables are created as follows:
-- SET search_path TO mimiciii;

with expected as
(
select 'admissions' as tbl, 58976 as row_count UNION ALL
select 'callout' as tbl, 34499 as row_count UNION ALL
select 'caregivers' as tbl, 7567 as row_count UNION ALL
select 'chartevents' as tbl, 330712483 as row_count UNION ALL
select 'cptevents' as tbl, 573146 as row_count UNION ALL
select 'd_cpt' as tbl, 134 as row_count UNION ALL
select 'd_icd_diagnoses' as tbl, 14567 as row_count UNION ALL
select 'd_icd_procedures' as tbl, 3882 as row_count UNION ALL
select 'd_items' as tbl, 12487 as row_count UNION ALL
select 'd_labitems' as tbl, 753 as row_count UNION ALL
select 'datetimeevents' as tbl, 4485937 as row_count UNION ALL
select 'diagnoses_icd' as tbl, 651047 as row_count UNION ALL
select 'drgcodes' as tbl, 125557 as row_count UNION ALL
select 'icustays' as tbl, 61532 as row_count UNION ALL
select 'inputevents_cv' as tbl, 17527935 as row_count UNION ALL
select 'inputevents_mv' as tbl, 3618991 as row_count UNION ALL
select 'labevents' as tbl, 27854055 as row_count UNION ALL
select 'microbiologyevents' as tbl, 631726 as row_count UNION ALL
select 'noteevents' as tbl, 2083180 as row_count UNION ALL
select 'outputevents' as tbl, 4349218 as row_count UNION ALL
select 'patients' as tbl, 46520 as row_count UNION ALL
select 'prescriptions' as tbl, 4156450 as row_count UNION ALL
select 'procedureevents_mv' as tbl, 258066 as row_count UNION ALL
select 'procedures_icd' as tbl, 240095 as row_count UNION ALL
select 'services' as tbl, 73343 as row_count UNION ALL
select 'transfers' as tbl, 261897 as row_count
)
, observed as
(
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
  select 'inputevents_mv' as tbl, count(*) as row_count from inputevents_mv UNION ALL
  select 'labevents' as tbl, count(*) as row_count from labevents UNION ALL
  select 'microbiologyevents' as tbl, count(*) as row_count from microbiologyevents UNION ALL
  select 'noteevents' as tbl, count(*) as row_count from noteevents UNION ALL
  select 'outputevents' as tbl, count(*) as row_count from outputevents UNION ALL
  select 'patients' as tbl, count(*) as row_count from patients UNION ALL
  select 'prescriptions' as tbl, count(*) as row_count from prescriptions UNION ALL
  select 'procedureevents_mv' as tbl, count(*) as row_count from procedureevents_mv UNION ALL
  select 'procedures_icd' as tbl, count(*) as row_count from procedures_icd UNION ALL
  select 'services' as tbl, count(*) as row_count from services UNION ALL
  select 'transfers' as tbl, count(*) as row_count from transfers
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
