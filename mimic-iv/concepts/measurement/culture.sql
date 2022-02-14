-- The microbiologyevents table has multiple rows per culture 
-- for distinct organisms/antibiotic sensitivities.
-- This query collapses it into one row per culture.

-- selected columns are identical for all rows of the same micro_specimen_id
-- aggregates simply collapse duplicates down to 1 row
SELECT
  MAX(subject_id) AS subject_id
, MAX(hadm_id) AS hadm_id
, micro_specimen_id
, CAST(MAX(chartdate) AS DATE) AS chartdate
, MAX(charttime) AS charttime
, MAX(
    -- clean up the specimen a bit
    CASE
    WHEN spec_type_desc IN (
        'BLOOD',
        'BLOOD CULTURE',
        'BLOOD CULTURE ( MYCO/F LYTIC BOTTLE)',
        'BLOOD CULTURE (POST-MORTEM)',
        'BLOOD CULTURE - NEONATE',
        'Blood (CMV AB)',
        'Blood (EBV)',
        'Blood (LYME)',
        'Blood (Malaria)',
        'Blood (Toxo)'
    ) THEN 'BLOOD'
    WHEN spec_type_desc IN (
        'BONE MARROW',
        'BONE MARROW - CYTOGENETICS'
    ) THEN 'BONE MARROW'
    WHEN spec_type_desc IN (
        'BRONCHOALVEOLAR LAVAGE',
        'Influenza A/B by DFA - Bronch Lavage',
        'Mini-BAL'
    ) THEN 'BRONCHOALVEOLAR LAVAGE'
    WHEN spec_type_desc IN (
        'BRONCHIAL BRUSH',
        'BRONCHIAL BRUSH - PROTECTED'
    ) THEN 'BRONCHIAL BRUSH'
    WHEN spec_type_desc IN (
        'FOREIGN BODY',
        'Foreign Body - Sonication Culture'
    ) THEN 'FOREIGN BODY'
    WHEN spec_type_desc IN (
        'FLUID RECEIVED IN BLOOD CULTURE BOTTLES',
        'FLUID,OTHER'
    ) THEN 'FLUID,OTHER'
    WHEN spec_type_desc IN (
        'STOOL',
        'STOOL (RECEIVED IN TRANSPORT SYSTEM)'
    ) THEN 'STOOL'
    WHEN spec_type_desc IN (
        'Swab',
        'Swab R/O Yeast Screen',
        'SWAB',
        'SWAB - R/O YEAST',
        'SWAB, R/O GC'
    ) THEN 'SWAB'
    WHEN spec_type_desc IN (
        'THROAT',
        'THROAT CULTURE',
        'THROAT FOR STREP'
    ) THEN 'THROAT'
    WHEN spec_type_desc IN (
        'VIRAL CULTURE',
        'VIRAL CULTURE: R/O CYTOMEGALOVIRUS',
        'VIRAL CULTURE:R/O HERPES SIMPLEX VIRUS',
        'Immunology (CMV)'
    ) THEN 'VIRAL CULTURE'
    ELSE spec_type_desc END
    -- list of values we allow through
    -- 'ABSCESS',
    -- 'AMNIOTIC FLUID',
    -- 'ANORECTAL/VAGINAL CULTURE',
    -- 'ARTHROPOD',
    -- 'ASPIRATE',
    -- 'BILE',
    -- 'BIOPSY',
    -- 'BLOOD BAG FLUID',
    -- 'BRONCHIAL WASHINGS',
    -- 'CATHETER OR LINE',
    -- 'CHLAMYDIA CULTURE',
    -- 'CHORIONIC VILLUS SAMPLE',
    -- 'CORNEAL EYE SCRAPINGS',
    -- 'CSF;SPINAL FLUID',
    -- 'DIALYSIS FLUID',
    -- 'EAR',
    -- 'EYE',
    -- 'FECAL SWAB',
    -- 'FLUID WOUND',
    -- 'FOOT CULTURE',
    -- 'HAIR',
    -- 'IMMUNOLOGY',
    -- 'Infection Control Yeast',
    -- 'Influenza A/B by DFA',
    -- 'Isolate',
    -- 'JOINT FLUID',
    -- 'MICRO PROBLEM PATIENT',
    -- 'NAIL SCRAPINGS',
    -- 'NEOPLASTIC BLOOD',
    -- 'PERIPHERAL BLOOD LYMPHOCYTES',
    -- 'PERITONEAL FLUID',
    -- 'PLEURAL FLUID',
    -- 'POSTMORTEM CULTURE',
    -- 'PROSTHETIC JOINT FLUID',
    -- 'RECTAL - R/O GC',
    -- 'SEROLOGY/BLOOD',
    -- 'SKIN SCRAPINGS',
    -- 'SPUTUM',
    -- 'Stem Cell - Blood Culture',
    -- 'TISSUE',
    -- 'TRACHEAL ASPIRATE',
    -- 'Touch Prep/Sections',
    -- 'URINE',
    -- 'URINE,KIDNEY',
    -- 'URINE,PROSTATIC MASSAGE',
    -- 'URINE,SUPRAPUBIC ASPIRATE',
    -- 'VARICELLA-ZOSTER CULTURE',
    -- 'XXX',
    -- viral cultures
    -- 'DIRECT ANTIGEN TEST FOR VARICELLA-ZOSTER VIRUS',
    -- 'Direct Antigen Test for Herpes Simplex Virus Types 1 & 2',
    -- 'POST-MORTEM VIRAL CULTURE',
    -- 'RAPID RESPIRATORY VIRAL ANTIGEN TEST',
    -- 'Rapid Respiratory Viral Screen & Culture'
    -- screening
    -- 'C, E, & A Screening',
    -- 'CRE Screen',
    -- 'Cipro Resistant Screen',
    -- 'Staph aureus Screen',
    -- 'MRSA SCREEN',
) AS specimen
, MAX(test_name) AS test_name
, MAX(
    CASE WHEN spec_type_desc IN
    (
        'Cipro Resistant Screen',
        'C, E, & A Screening', -- CRE/ESBL/AMP-C Screening
        'CRE Screen',
        'MRSA SCREEN',
        'Rapid Respiratory Viral Screen & Culture',
        'Staph aureus Screen'
    )
    OR test_name IN
    (
        'ASO Screen',
        'Cipro Resistant Screen',
        'MRSA SCREEN'
    ) THEN 1
    ELSE 0 END
) AS screen
, MAX(
    CASE
    WHEN org_name IS NULL THEN 0
    WHEN TRIM(org_name) != '' THEN 0
    WHEN org_name IN ('NO GROWTH', 'NEGATIVE', 'CANCELLED') THEN 0
    ELSE 1 END) as positive_culture
, MAX(
    CASE
    WHEN ab_name IS NULL THEN 0
    WHEN TRIM(ab_name) != '' THEN 0
    ELSE 1 END
) as has_sensitivity
FROM `physionet-data.mimic_hosp.microbiologyevents`
GROUP BY micro_specimen_id