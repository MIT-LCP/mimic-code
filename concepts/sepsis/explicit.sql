-- This code extracts explicit sepsis using ICD-9 diagnosis codes
-- That is, the two codes 995.92 (severe sepsis) or 785.52 (septic shock)
-- These codes are extremely specific to sepsis, but have very low sensitivity
-- From Iwashyna et al. (vs. chart reviews): 100% PPV, 9.3% sens, 100% specificity

DROP MATERIALIZED VIEW IF EXISTS explicit_sepsis CASCADE;
CREATE MATERIALIZED VIEW explicit_sepsis as
WITH co_dx AS
(
	SELECT hadm_id
	-- sepsis codes
	, MAX(
    	CASE
    		WHEN icd9_code = '99592' THEN 1
      ELSE 0 END
    ) AS severe_sepsis
	, MAX(
    	CASE
    		WHEN icd9_code = '78552' THEN 1
      ELSE 0 END
    ) AS septic_shock
  FROM diagnoses_icd
  GROUP BY hadm_id
)
select
  adm.subject_id
  , adm.hadm_id
	, co_dx.severe_sepsis
  , co_dx.septic_shock
	, case when co_dx.severe_sepsis = 1 or co_dx.septic_shock = 1
			then 1
		else 0 end as sepsis
FROM admissions adm
left join co_dx
  on adm.hadm_id = co_dx.hadm_id
order by adm.subject_id, adm.hadm_id;
