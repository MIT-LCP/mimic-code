drop table if exists angus; create table angus as 
-- ICD-9 codes for Angus criteria of sepsis

-- Angus et al, 2001. Epidemiology of severe sepsis in the United States
-- http://www.ncbi.nlm.nih.gov/pubmed/11445675

-- Case selection and definitions
-- To identify cases with severe sepsis, we selected all acute care
-- hospitalizations with ICD-9-CM codes for both:
-- (a) a bacterial or fungal infectious process AND
-- (b) a diagnosis of acute organ dysfunction (Appendix 2).

-- ICD-9 codes for infection - as sourced from Appendix 1 of above paper
with infection_group as
(
	select subject_id, hadm_id,
	case
		when substr(icd9_code,1,3) in ('001','002','003','004','005','008',
			   '009','010','011','012','013','014','015','016','017','018',
			   '020','021','022','023','024','025','026','027','030','031',
			   '032','033','034','035','036','037','038','039','040','041',
			   '090','091','092','093','094','095','096','097','098','100',
			   '101','102','103','104','110','111','112','114','115','116',
			   '117','118','320','322','324','325','420','421','451','461',
			   '462','463','464','465','481','482','485','486','494','510',
			   '513','540','541','542','566','567','590','597','601','614',
			   '615','616','681','682','683','686','730') THEN 1
		when substr(icd9_code,1,4) in ('5695','5720','5721','5750','5990','7110',
				'7907','9966','9985','9993') then 1
		when substr(icd9_code,1,5) in ('49121','56201','56203','56211','56213',
				'56983') then 1
		else 0 end as infection
	from diagnoses_icd
),
-- ICD-9 codes for organ dysfunction - as sourced from Appendix 2 of above paper
organ_diag_group as
(
	select subject_id, hadm_id,
		case
		-- acute organ dysfunction diagnosis codes
		when substr(icd9_code,1,3) in ('458','293','570','584') then 1
		when substr(icd9_code,1,4) in ('7855','3483','3481',
				'2874','2875','2869','2866','5734')  then 1
		else 0 end as organ_dysfunction,
		-- Explicit diagnosis of severe sepsis or septic shock
		case
		when substr(icd9_code,1,5) in ('99592','78552')  then 1
		else 0 end as explicit_sepsis
	from diagnoses_icd
),
-- Mechanical ventilation
organ_proc_group as
(
	select subject_id, hadm_id,
		case
		when icd9_code in ('9670', '9671', '9672') then 1
		else 0 end as mech_vent
	from procedures_icd
),
-- Aggregate above views together
aggregate as
(
	select subject_id, hadm_id,
		case
			when hadm_id in
					(select distinct hadm_id
					from infection_group
					where infection = 1)
				then 1
			else 0 end as infection,
		case
			when hadm_id in
					(select distinct hadm_id
					from organ_diag_group
					where explicit_sepsis = 1)
				then 1
			else 0 end as explicit_sepsis,
		case
			when hadm_id in
					(select distinct hadm_id
					from organ_diag_group
					where organ_dysfunction = 1)
				then 1
			else 0 end as organ_dysfunction,
		case
		when hadm_id in
				(select distinct hadm_id
				from organ_proc_group
				where mech_vent = 1)
			then 1
		else 0 end as mech_vent
	from admissions
)
-- output component flags (explicit sepsis, organ dysfunction) and final flag (angus)
select subject_id, hadm_id, infection,
   explicit_sepsis, organ_dysfunction, mech_vent,
case
	when explicit_sepsis = 1 then 1
	when infection = 1 and organ_dysfunction = 1 then 1
	when infection = 1 and mech_vent = 1 then 1
	else 0 end
as angus
from aggregate;