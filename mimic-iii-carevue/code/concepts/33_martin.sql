drop table if exists martin; create table martin as 
-- ICD-9 codes for sepsis as validated by Martin et al.

-- Greg S. Martin, David M. Mannino, Stephanie Eaton, and Marc Moss. The epidemiology of
-- sepsis in the united states from 1979 through 2000. N Engl J Med, 348(16):1546–1554, Apr
-- 2003. doi: 10.1056/NEJMoa022139. URL http://dx.doi.org/10.1056/NEJMoa022139.

with co_dx as
(
  select subject_id, hadm_id
    , max(
      case
        -- septicemia
        when substr(icd9_code,1,3) = '038' then 1
        -- septicemic, bacteremia, disseminated fungal infection, disseminated candida infection
        -- NOTE: the paper specifies 020.0 ... but this is bubonic plague
        -- presumably, they meant 020.2, which is septicemic plague
        when substr(icd9_code,1,4) in ('0202','7907','1179','1125') then 1
        -- disseminated fungal endocarditis
        when substr(icd9_code,1,5) = '11281' then 1
      else 0 end
    ) as sepsis
    , max(
      case
        when substr(icd9_code,1,4) in ('7991') then 1
        when substr(icd9_code,1,5) in ('51881','51882','51885','78609') then 1
      else 0 end
    ) as respiratory
    , max(
      case
        when substr(icd9_code,1,4) in ('4580','7855','4580','4588','4589','7963') then 1
        when substr(icd9_code,1,5) in ('785.51','785.59') then 1
      else 0 end
    ) as cardiovascular
    , max(
      case
        when substr(icd9_code,1,3) in ('584','580','585') then 1
      else 0 end
    ) as renal
    , max(
      case
        when substr(icd9_code,1,3) in ('570') then 1
        when substr(icd9_code,1,4) in ('5722','5733') then 1
      else 0 end
    ) as hepatic
    , max(
      case
        when substr(icd9_code,1,4) in ('2862','2866','2869','2873','2874','2875') then 1
      else 0 end
    ) as hematologic
    , max(
      case
        when substr(icd9_code,1,4) in ('2762') then 1
      else 0 end
    ) as metabolic
    , max(
      case
        when substr(icd9_code,1,3) in ('293') then 1
        when substr(icd9_code,1,4) in ('3481','3483') then 1
        when substr(icd9_code,1,5) in ('78001','78009') then 1
      else 0 end
    ) as neurologic
  from diagnoses_icd
  group by subject_id, hadm_id
)
-- procedure codes:
-- "96.7 - Ventilator management"
-- translated:
--    9670  Continuous invasive mechanical ventilation of unspecified duration
--    9671  Continuous invasive mechanical ventilation for less than 96 consecutive hours
--    9672  Continuous invasive mechanical ventilation for 96 consecutive hours or more
-- "39.95 - Hemodialysis"
--    3995  Hemodialysis
-- "89.14 - Electroencephalography"
--    8914  Electroencephalogram
, co_proc as
(
  select 
    subject_id, hadm_id
    , max(case when icd9_code = '967' then 1 else 0 end) as respiratory
    , max(case when icd9_code = '3995' then 1 else 0 end) as renal
    , max(case when icd9_code = '8914' then 1 else 0 end) as neurologic
  from procedures_icd
  group by subject_id, hadm_id
)
select 
  adm.subject_id, adm.hadm_id
  , co_dx.sepsis
  , case
    when co_dx.respiratory = 1 or co_proc.respiratory = 1
      or co_dx.cardiovascular = 1
      or co_dx.renal = 1 or co_proc.renal = 1
      or co_dx.hepatic = 1
      or co_dx.hematologic = 1
      or co_dx.metabolic = 1
      or co_dx.neurologic = 1 or co_proc.neurologic = 1
    then 1
    else 0 
  end as organ_failure
  , case when co_dx.respiratory = 1 or co_proc.respiratory = 1 then 1 else 0 end as respiratory
  , co_dx.cardiovascular
  , case when co_dx.renal = 1 or co_proc.renal = 1 then 1 else 0 end as renal
  , co_dx.hepatic
  , co_dx.hematologic
  , co_dx.metabolic
  , case when co_dx.neurologic = 1 or co_proc.neurologic = 1 then 1 else 0 end as neurologic
from admissions adm
left join co_dx
  on adm.hadm_id = co_dx.hadm_id
left join co_proc
  on adm.hadm_id = co_proc.hadm_id;