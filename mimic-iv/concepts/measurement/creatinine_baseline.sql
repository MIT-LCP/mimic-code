-- This query extracts the serum creatinine baselines of adult patients on each hospital admission.
-- The baseline is determined by the following rules:
--     i. if the lowest creatinine value during this admission is normal (<1.1), then use the value
--     ii. if the patient is diagnosed with chronic kidney disease (CKD), then use the lowest creatinine value during the admission, although it may be rather large.
--     iii. Otherwise, we estimate the baseline using the Simplified MDRD Formula:
--          eGFR = 186 × Scr^(-1.154) × Age^(-0.203) × 0.742Female
--     Let eGFR = 75. Scr = [ 75 / 186 / Age^(-0.203) / (0.742Female) ] ^ (1/-1.154)
WITH p as
(
    SELECT 
        ag.subject_id
        , ag.hadm_id
        , ag.age
        , p.gender
        , CASE WHEN p.gender='F' THEN 
            POWER(75.0 / 186.0 / POWER(ag.age, -0.203) / 0.742, -1/1.154)
            ELSE 
            POWER(75.0 / 186.0 / POWER(ag.age, -0.203), -1/1.154)
            END 
            AS MDRD_est
    FROM `physionet-data.mimiciv_derived.age` ag
    LEFT JOIN `physionet-data.mimiciv_hosp.patients` p
    ON ag.subject_id = p.subject_id
    WHERE ag.age >= 18
)
, lab as
(
    SELECT 
        hadm_id
        , MIN(creatinine) AS scr_min
    FROM `physionet-data.mimiciv_derived.chemistry`
    GROUP BY hadm_id
)
, ckd as 
(
    SELECT hadm_id, MAX(1) AS CKD_flag
    FROM `physionet-data.mimiciv_hosp.diagnoses_icd`
    WHERE 
        (
            SUBSTR(icd_code, 1, 3) = '585'
            AND 
            icd_version = 9
        )
    OR 
        (
            SUBSTR(icd_code, 1, 3) = 'N18'
            AND 
            icd_version = 10
        )
    GROUP BY 1
)
SELECT 
    p.hadm_id
    , p.gender
    , p.age
    , lab.scr_min
    , COALESCE(ckd.ckd_flag, 0) AS ckd
    , p.MDRD_est
    , CASE 
    WHEN lab.scr_min<=1.1 THEN scr_min
    WHEN ckd.ckd_flag=1 THEN scr_min
    ELSE MDRD_est END AS scr_baseline
FROM p
LEFT JOIN lab
ON p.hadm_id = lab.hadm_id
LEFT JOIN ckd
ON p.hadm_id = ckd.hadm_id
;

