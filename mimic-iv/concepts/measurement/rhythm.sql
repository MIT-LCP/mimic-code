-- Heart rhythm related documentation
SELECT
    ce.subject_id
    , ce.charttime
    , MAX(CASE WHEN itemid = 220048 THEN value ELSE NULL END) AS heart_rhythm
    , MAX(CASE WHEN itemid = 224650 THEN value ELSE NULL END) AS ectopy_type
    , MAX(
        CASE WHEN itemid = 224651 THEN value ELSE NULL END
    ) AS ectopy_frequency
    , MAX(
        CASE WHEN itemid = 226479 THEN value ELSE NULL END
    ) AS ectopy_type_secondary
    , MAX(
        CASE WHEN itemid = 226480 THEN value ELSE NULL END
    ) AS ectopy_frequency_secondary
FROM `physionet-data.mimiciv_icu.chartevents` ce
WHERE ce.stay_id IS NOT NULL
    AND ce.itemid IN
    (
        220048 -- Heart Rhythm
        , 224650 -- Ectopy Type 1
        , 224651 -- Ectopy Frequency 1
        , 226479 -- Ectopy Type 2
        , 226480  -- Ectopy Frequency 2
    )
GROUP BY ce.subject_id, ce.charttime
;
