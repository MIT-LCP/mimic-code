-- This query extracts code status with the time at which the
-- code status was documented.

WITH t1 AS (
  /*
There are five distinct values for the code status order in the ICU data:
1 DNR / DNI
2	DNI (do not intubate)
3	Comfort measures only
4	Full code
5	DNR (do not resuscitate)
 */

    SELECT
        subject_id
        , hadm_id
        , stay_id
        , charttime
        -- coalesce the values
        , CASE
            WHEN value IN ('Full code') THEN 1
            ELSE 0 END AS fullcode
        , CASE
            WHEN value IN ('Comfort measures only') THEN 1
            ELSE 0 END AS cmo
        , CASE
            WHEN value IN ('DNI (do not intubate)', 'DNR / DNI') THEN 1
            ELSE 0 END AS dni
        , CASE
            WHEN value IN ('DNR (do not resuscitate)', 'DNR / DNI') THEN 1
            ELSE 0 END AS dnr
    FROM `physionet-data.mimiciv_icu.chartevents`
    WHERE itemid IN (223758)
)

-- Provider order entry contains hospital wide orders for code status changes
-- Interestingly, it does not contain comfort measures only orders
, poe AS (
    SELECT p.subject_id
        , p.hadm_id
        , ie.stay_id
        , p.ordertime
        , CASE
            WHEN pd.field_value = 'Resuscitate (Full code)' THEN 1
            WHEN pd.field_value = 'Full code  (attempt resuscitation)' THEN 1
            ELSE 0 END AS fullcode
        , CASE
            WHEN

                pd.field_value = 'DNAR (DO NOT attempt resuscitation for cardiac arrest) ' THEN 1 -- noqa
            WHEN pd.field_value = 'Do not resuscitate (DNR/DNI)' THEN 1
            ELSE 0 END AS dnr
        , CASE
            WHEN pd.field_value = 'Do not resuscitate (DNR/DNI)' THEN 1
            ELSE 0 END AS dni
    FROM `physionet-data.mimiciv_hosp.poe` p
    INNER JOIN `physionet-data.mimiciv_hosp.poe_detail` pd
        ON p.poe_id = pd.poe_id
    LEFT JOIN `physionet-data.mimiciv_icu.icustays` ie
        ON p.hadm_id = ie.hadm_id
            AND p.ordertime >= ie.intime
            AND p.ordertime <= ie.outtime
    WHERE p.order_type = 'General Care'
        AND order_subtype = 'Code status'
)

-- Merge together code status from ICU data
-- with code status from provider order entry
SELECT t1.subject_id, t1.hadm_id, t1.stay_id
    , t1.charttime
    , t1.fullcode, t1.cmo, t1.dni, t1.dnr
FROM t1
UNION ALL
SELECT poe.subject_id, poe.hadm_id, poe.stay_id
    , poe.ordertime AS charttime
    , poe.fullcode, 0 AS cmo, poe.dni, poe.dnr
FROM poe
;
