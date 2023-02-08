SELECT
    MAX(subject_id) AS subject_id
    , MAX(hadm_id) AS hadm_id
    , MAX(charttime) AS charttime
    , le.specimen_id
    -- convert from itemid into a meaningful column
    , MAX(CASE WHEN itemid = 50889 THEN valuenum ELSE NULL END) AS crp
FROM `physionet-data.mimiciv_hosp.labevents` le
WHERE le.itemid IN
    (
        -- 51652 -- high sensitivity CRP
        50889 -- crp
    )
    AND valuenum IS NOT NULL
    -- lab values cannot be 0 and cannot be negative
    AND valuenum > 0
GROUP BY le.specimen_id
;
