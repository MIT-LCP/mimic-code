drop table if exists explicit; create table explicit as 
-- This code extracts explicit sepsis using ICD-9 diagnosis codes
-- That is, the two codes 995.92 (severe sepsis) or 785.52 (septic shock)
-- These codes are extremely specific to sepsis, but have very low sensitivity
-- From Iwashyna et al. (vs. chart reviews): 100% PPV, 9.3% sens, 100% specificity

with co_dx as
(
	select hadm_id
	-- sepsis codes
	, max(
    	case
    		when icd9_code = '99592' then 1
      else 0 end
    ) as severe_sepsis
	, max(
    	case
    		when icd9_code = '78552' then 1
      else 0 end
    ) as septic_shock
  from diagnoses_icd
  group by hadm_id
)
select
  adm.subject_id
  , adm.hadm_id
	, co_dx.severe_sepsis
  , co_dx.septic_shock
	, case when co_dx.severe_sepsis = 1 or co_dx.septic_shock = 1
			then 1
		else 0 end as sepsis
from admissions adm
left join co_dx
  on adm.hadm_id = co_dx.hadm_id
order by adm.subject_id, adm.hadm_id;