-- ICD-9 codes for Angus criteria of sepsis

-- Angus et al, 2001. Epidemiology of severe sepsis in the United States
-- http://www.ncbi.nlm.nih.gov/pubmed/11445675

-- Case selection and definitions
-- To identify cases with severe sepsis, we selected all acute care
-- hospitalizations with ICD-9-CM codes for both:
-- (a) a bacterial or fungal infectious process AND
-- (b) a diagnosis of acute organ dysfunction (Appendix 2).

-- ICD-9 codes for infection - as sourced from Appendix 1 of above paper
WITH infection_group AS
(
	SELECT subject_id, hadm_id,
	CASE
		WHEN SUBSTR(icd9_code,1,3) IN ('001','002','003','004','005','008',
			   '009','010','011','012','013','014','015','016','017','018',
			   '020','021','022','023','024','025','026','027','030','031',
			   '032','033','034','035','036','037','038','039','040','041',
			   '090','091','092','093','094','095','096','097','098','100',
			   '101','102','103','104','110','111','112','114','115','116',
			   '117','118','320','322','324','325','420','421','451','461',
			   '462','463','464','465','481','482','485','486','494','510',
			   '513','540','541','542','566','567','590','597','601','614',
			   '615','616','681','682','683','686','730') THEN 1
		WHEN SUBSTR(icd9_code,1,4) IN ('5695','5720','5721','5750','5990','7110',
				'7907','9966','9985','9993') THEN 1
		WHEN SUBSTR(icd9_code,1,5) IN ('49121','56201','56203','56211','56213',
				'56983') THEN 1
		ELSE 0 END AS infection
	from `physionet-data.mimiciii_clinical.diagnoses_icd`
),
-- ICD-9 codes for organ dysfunction - as sourced from Appendix 2 of above paper
organ_diag_group as
(
	SELECT subject_id, hadm_id,
		CASE
		-- Acute Organ Dysfunction Diagnosis Codes
		WHEN SUBSTR(icd9_code,1,3) IN ('458','293','570','584') THEN 1
		WHEN SUBSTR(icd9_code,1,4) IN ('7855','3483','3481',
				'2874','2875','2869','2866','5734')  THEN 1
		ELSE 0 END AS organ_dysfunction,
		-- Explicit diagnosis of severe sepsis or septic shock
		CASE
		WHEN SUBSTR(icd9_code,1,5) IN ('99592','78552')  THEN 1
		ELSE 0 END AS explicit_sepsis
	from `physionet-data.mimiciii_clinical.diagnoses_icd`
),
-- Mechanical ventilation
organ_proc_group as
(
	SELECT subject_id, hadm_id,
		CASE
		WHEN icd9_code IN ('9670', '9671', '9672') THEN 1
		ELSE 0 END AS mech_vent
	FROM `physionet-data.mimiciii_clinical.procedures_icd`
),
-- Aggregate above views together
aggregate as
(
	SELECT subject_id, hadm_id,
		CASE
			WHEN hadm_id in
					(SELECT DISTINCT hadm_id
					FROM infection_group
					WHERE infection = 1)
				THEN 1
			ELSE 0 END AS infection,
		CASE
			WHEN hadm_id in
					(SELECT DISTINCT hadm_id
					FROM organ_diag_group
					WHERE explicit_sepsis = 1)
				THEN 1
			ELSE 0 END AS explicit_sepsis,
		CASE
			WHEN hadm_id in
					(SELECT DISTINCT hadm_id
					FROM organ_diag_group
					WHERE organ_dysfunction = 1)
				THEN 1
			ELSE 0 END AS organ_dysfunction,
		CASE
		WHEN hadm_id in
				(SELECT DISTINCT hadm_id
				FROM organ_proc_group
				WHERE mech_vent = 1)
			THEN 1
		ELSE 0 END AS mech_vent
	FROM `physionet-data.mimiciii_clinical.admissions`
)
-- Output component flags (explicit sepsis, organ dysfunction) and final flag (angus)
SELECT subject_id, hadm_id, infection,
   explicit_sepsis, organ_dysfunction, mech_vent,
CASE
	WHEN explicit_sepsis = 1 THEN 1
	WHEN infection = 1 AND organ_dysfunction = 1 THEN 1
	WHEN infection = 1 AND mech_vent = 1 THEN 1
	ELSE 0 END
AS angus
FROM aggregate;
