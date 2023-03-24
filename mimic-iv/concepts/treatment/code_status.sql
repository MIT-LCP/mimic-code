-- This query extracts:
--    i) a patient's first code status
--    ii) a patient's last code status
--    iii) the time of the first entry of DNR or CMO

WITH t1 AS (
  /*
There are five distinct values for the code status order in the dataset:
1 DNR / DNI
2	DNI (do not intubate)
3	Comfort measures only
4	Full code
5	DNR (do not resuscitate)
 */

    SELECT
        stay_id
        , charttime
        , value
        -- use row number to identify first and last code status
        , ROW_NUMBER() OVER (PARTITION BY stay_id ORDER BY charttime) AS rnfirst
        , ROW_NUMBER() OVER (
            PARTITION BY stay_id ORDER BY charttime DESC
        ) AS rnlast
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
    FROM `physionet-data.mimic_icu.chartevents`
    WHERE itemid IN (223758)
)

SELECT
    ie.subject_id
    , ie.hadm_id
    , ie.stay_id
    -- first recorded code status
    , MAX(
        CASE WHEN rnfirst = 1 THEN t1.fullcode END
    ) AS fullcode_first
    , MAX(CASE WHEN rnfirst = 1 THEN t1.cmo END) AS cmo_first
    , MAX(CASE WHEN rnfirst = 1 THEN t1.dnr END) AS dnr_first
    , MAX(CASE WHEN rnfirst = 1 THEN t1.dni END) AS dni_first

    -- last recorded code status
    , MAX(
        CASE WHEN rnlast = 1 THEN t1.fullcode END
    ) AS fullcode_last
    , MAX(CASE WHEN rnlast = 1 THEN t1.cmo END) AS cmo_last
    , MAX(CASE WHEN rnlast = 1 THEN t1.dnr END) AS dnr_last
    , MAX(CASE WHEN rnlast = 1 THEN t1.dni END) AS dni_last

    -- were they *at any time* given a certain code status
    , MAX(t1.fullcode) AS fullcode
    , MAX(t1.cmo) AS cmo
    , MAX(t1.dnr) AS dnr
    , MAX(t1.dni) AS dni

    -- time until their first DNR
    , MIN(CASE WHEN t1.dnr = 1 THEN t1.charttime END)
    AS dnr_first_charttime
    , MIN(CASE WHEN t1.dni = 1 THEN t1.charttime END)
    AS dni_first_charttime

    -- first code status of CMO
    , MIN(CASE WHEN t1.cmo = 1 THEN t1.charttime END)
    AS timecmo_chart

FROM `physionet-data.mimic_icu.icustays` AS ie
LEFT JOIN t1
          ON ie.stay_id = t1.stay_id
GROUP BY ie.subject_id, ie.hadm_id, ie.stay_id, ie.intime;
