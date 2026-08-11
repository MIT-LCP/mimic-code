-- remove all but the first 10 subjects
-- mimiciv_hosp.demo_subject_id
DELETE FROM mimiciv_hosp.patients
WHERE subject_id NOT IN 
(SELECT subject_id FROM mimiciv_hosp.patients ORDER BY subject_id LIMIT 10);

-- apply this to all the other tables
DELETE FROM mimiciv_hosp.admissions WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.diagnoses_icd WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.drgcodes WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.emar WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.emar_detail WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.hcpcsevents WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.labevents WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.microbiologyevents WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.omr WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.pharmacy WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.poe WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.poe_detail WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.prescriptions WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.procedures_icd WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.services WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_hosp.transfers WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);

DELETE FROM mimiciv_icu.chartevents WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_icu.datetimeevents WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_icu.icustays WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_icu.ingredientevents WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_icu.inputevents WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_icu.outputevents WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);
DELETE FROM mimiciv_icu.procedureevents WHERE subject_id NOT IN (SELECT subject_id FROM mimiciv_hosp.patients);


-- d_hcpcs
-- d_icd_diagnoses
-- d_icd_procedures
-- d_items
-- d_labitems
-- caregiver
-- provider

-- to reduce the filesize, the database will need to be exported and reimported
EXPORT DATABASE 'tmp_output';

IMPORT DATABASE 'tmp_output';