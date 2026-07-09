-- =====================================================================
-- PostgreSQL version of BigQuery pivoted-lab.sql (MIMIC-III)
-- Purpose: Pivot common labs from LABEVENTS, and assign hadm_id/icustay_id
--          using "fuzzy" admission/ICU windows.
--
-- Output table:
--   mimiciii_derived.pivoted_lab
--
-- Source tables:
--   mimiciii_clinical.icustays
--   mimiciii_clinical.admissions
--   mimiciii_clinical.labevents
-- =====================================================================

DROP TABLE IF EXISTS mimiciii_derived.pivoted_lab;

CREATE TABLE mimiciii_derived.pivoted_lab AS
WITH i AS
(
  SELECT
      subject_id
    , icustay_id
    , intime
    , outtime
    , LAG(outtime) OVER (PARTITION BY subject_id ORDER BY intime) AS outtime_lag
    , LEAD(intime) OVER (PARTITION BY subject_id ORDER BY intime) AS intime_lead
  FROM mimiciii_clinical.icustays
)
, iid_assign AS
(
  SELECT
      i.subject_id
    , i.icustay_id
    , CASE
        WHEN i.outtime_lag IS NOT NULL
         AND i.outtime_lag > (i.intime - INTERVAL '24' HOUR)
        THEN i.intime
             - (INTERVAL '1' SECOND * CAST(EXTRACT(EPOCH FROM (i.intime - i.outtime_lag))/2 AS BIGINT))
        ELSE i.intime - INTERVAL '12' HOUR
      END AS data_start
    , CASE
        WHEN i.intime_lead IS NOT NULL
         AND i.intime_lead < (i.outtime + INTERVAL '24' HOUR)
        THEN i.outtime
             + (INTERVAL '1' SECOND * CAST(EXTRACT(EPOCH FROM (i.intime_lead - i.outtime))/2 AS BIGINT))
        ELSE i.outtime + INTERVAL '12' HOUR
      END AS data_end
  FROM i
)
, h AS
(
  SELECT
      subject_id
    , hadm_id
    , admittime
    , dischtime
    , LAG(dischtime) OVER (PARTITION BY subject_id ORDER BY admittime) AS dischtime_lag
    , LEAD(admittime) OVER (PARTITION BY subject_id ORDER BY admittime) AS admittime_lead
  FROM mimiciii_clinical.admissions
)
, adm AS
(
  SELECT
      h.subject_id
    , h.hadm_id
    , CASE
        WHEN h.dischtime_lag IS NOT NULL
         AND h.dischtime_lag > (h.admittime - INTERVAL '24' HOUR)
        THEN h.admittime
             - (INTERVAL '1' SECOND * CAST(EXTRACT(EPOCH FROM (h.admittime - h.dischtime_lag))/2 AS BIGINT))
        ELSE h.admittime - INTERVAL '12' HOUR
      END AS data_start
    , CASE
        WHEN h.admittime_lead IS NOT NULL
         AND h.admittime_lead < (h.dischtime + INTERVAL '24' HOUR)
        THEN h.dischtime
             + (INTERVAL '1' SECOND * CAST(EXTRACT(EPOCH FROM (h.admittime_lead - h.dischtime))/2 AS BIGINT))
        ELSE h.dischtime + INTERVAL '12' HOUR
      END AS data_end
  FROM h
)
, le_avg AS
(
  SELECT
      pvt.subject_id
    , pvt.charttime
    , AVG(CASE WHEN label = 'ANION GAP'   THEN valuenum ELSE NULL END) AS aniongap
    , AVG(CASE WHEN label = 'ALBUMIN'     THEN valuenum ELSE NULL END) AS albumin
    , AVG(CASE WHEN label = 'BANDS'       THEN valuenum ELSE NULL END) AS bands
    , AVG(CASE WHEN label = 'BICARBONATE' THEN valuenum ELSE NULL END) AS bicarbonate
    , AVG(CASE WHEN label = 'BILIRUBIN'   THEN valuenum ELSE NULL END) AS bilirubin
    , AVG(CASE WHEN label = 'CREATININE'  THEN valuenum ELSE NULL END) AS creatinine
    , AVG(CASE WHEN label = 'CHLORIDE'    THEN valuenum ELSE NULL END) AS chloride
    , AVG(CASE WHEN label = 'GLUCOSE'     THEN valuenum ELSE NULL END) AS glucose
    , AVG(CASE WHEN label = 'HEMATOCRIT'  THEN valuenum ELSE NULL END) AS hematocrit
    , AVG(CASE WHEN label = 'HEMOGLOBIN'  THEN valuenum ELSE NULL END) AS hemoglobin
    , AVG(CASE WHEN label = 'LACTATE'     THEN valuenum ELSE NULL END) AS lactate
    , AVG(CASE WHEN label = 'PLATELET'    THEN valuenum ELSE NULL END) AS platelet
    , AVG(CASE WHEN label = 'POTASSIUM'   THEN valuenum ELSE NULL END) AS potassium
    , AVG(CASE WHEN label = 'PTT'         THEN valuenum ELSE NULL END) AS ptt
    , AVG(CASE WHEN label = 'INR'         THEN valuenum ELSE NULL END) AS inr
    , AVG(CASE WHEN label = 'PT'          THEN valuenum ELSE NULL END) AS pt
    , AVG(CASE WHEN label = 'SODIUM'      THEN valuenum ELSE NULL END) AS sodium
    , AVG(CASE WHEN label = 'BUN'         THEN valuenum ELSE NULL END) AS bun
    , AVG(CASE WHEN label = 'WBC'         THEN valuenum ELSE NULL END) AS wbc
  FROM
  (
    SELECT
        le.subject_id
      , le.hadm_id
      , le.charttime
      , CASE
          WHEN itemid = 50868 THEN 'ANION GAP'
          WHEN itemid = 50862 THEN 'ALBUMIN'
          WHEN itemid = 51144 THEN 'BANDS'
          WHEN itemid = 50882 THEN 'BICARBONATE'
          WHEN itemid = 50885 THEN 'BILIRUBIN'
          WHEN itemid = 50912 THEN 'CREATININE'
          WHEN itemid = 50902 THEN 'CHLORIDE'
          WHEN itemid = 50931 THEN 'GLUCOSE'
          WHEN itemid = 51221 THEN 'HEMATOCRIT'
          WHEN itemid = 51222 THEN 'HEMOGLOBIN'
          WHEN itemid = 50813 THEN 'LACTATE'
          WHEN itemid = 51265 THEN 'PLATELET'
          WHEN itemid = 50971 THEN 'POTASSIUM'
          WHEN itemid = 51275 THEN 'PTT'
          WHEN itemid = 51237 THEN 'INR'
          WHEN itemid = 51274 THEN 'PT'
          WHEN itemid = 50983 THEN 'SODIUM'
          WHEN itemid = 51006 THEN 'BUN'
          WHEN itemid IN (51300, 51301) THEN 'WBC'
          ELSE NULL
        END AS label
      , CASE
          WHEN itemid = 50862 AND valuenum >    10 THEN NULL
          WHEN itemid = 50868 AND valuenum > 10000 THEN NULL
          WHEN itemid = 51144 AND valuenum <     0 THEN NULL
          WHEN itemid = 51144 AND valuenum >   100 THEN NULL
          WHEN itemid = 50882 AND valuenum > 10000 THEN NULL
          WHEN itemid = 50885 AND valuenum >   150 THEN NULL
          WHEN itemid = 50806 AND valuenum > 10000 THEN NULL
          WHEN itemid = 50902 AND valuenum > 10000 THEN NULL
          WHEN itemid = 50912 AND valuenum >   150 THEN NULL
          WHEN itemid = 50809 AND valuenum > 10000 THEN NULL
          WHEN itemid = 50931 AND valuenum > 10000 THEN NULL
          WHEN itemid = 50810 AND valuenum >   100 THEN NULL
          WHEN itemid = 51221 AND valuenum >   100 THEN NULL
          WHEN itemid = 50811 AND valuenum >    50 THEN NULL
          WHEN itemid = 51222 AND valuenum >    50 THEN NULL
          WHEN itemid = 50813 AND valuenum >    50 THEN NULL
          WHEN itemid = 51265 AND valuenum > 10000 THEN NULL
          WHEN itemid = 50822 AND valuenum >    30 THEN NULL
          WHEN itemid = 50971 AND valuenum >    30 THEN NULL
          WHEN itemid = 51275 AND valuenum >   150 THEN NULL
          WHEN itemid = 51237 AND valuenum >    50 THEN NULL
          WHEN itemid = 51274 AND valuenum >   150 THEN NULL
          WHEN itemid = 50824 AND valuenum >   200 THEN NULL
          WHEN itemid = 50983 AND valuenum >   200 THEN NULL
          WHEN itemid = 51006 AND valuenum >   300 THEN NULL
          WHEN itemid IN (51300, 51301) AND valuenum > 1000 THEN NULL
          ELSE valuenum
        END AS valuenum
    FROM mimiciii_clinical.labevents le
    WHERE le.itemid IN
    (
      50868, 50862, 51144, 50882, 50885, 50912, 50902,
      50931, 51221, 51222, 50813, 51265, 50971, 51275,
      51237, 51274, 50983, 51006, 51301, 51300
    )
      AND le.charttime IS NOT NULL
      AND le.valuenum IS NOT NULL
      AND le.valuenum > 0
  ) pvt
  GROUP BY pvt.subject_id, pvt.charttime
)
SELECT
    iid.icustay_id
  , adm.hadm_id
  , le_avg.subject_id
  , le_avg.charttime
  , le_avg.aniongap
  , le_avg.albumin
  , le_avg.bands
  , le_avg.bicarbonate
  , le_avg.bilirubin
  , le_avg.creatinine
  , le_avg.chloride
  , le_avg.glucose
  , le_avg.hematocrit
  , le_avg.hemoglobin
  , le_avg.lactate
  , le_avg.platelet
  , le_avg.potassium
  , le_avg.ptt
  , le_avg.inr
  , le_avg.pt
  , le_avg.sodium
  , le_avg.bun
  , le_avg.wbc
FROM le_avg
LEFT JOIN adm
  ON le_avg.subject_id = adm.subject_id
 AND le_avg.charttime >= adm.data_start
 AND le_avg.charttime  < adm.data_end
LEFT JOIN iid_assign iid
  ON le_avg.subject_id = iid.subject_id
 AND le_avg.charttime >= iid.data_start
 AND le_avg.charttime  < iid.data_end
ORDER BY le_avg.subject_id, le_avg.charttime;

-- Suggested indexes (optional, recommended)
-- CREATE INDEX IF NOT EXISTS idx_pivoted_lab_icustay_charttime
--   ON mimiciii_derived.pivoted_lab (icustay_id, charttime);
-- CREATE INDEX IF NOT EXISTS idx_pivoted_lab_hadm_charttime
--   ON mimiciii_derived.pivoted_lab (hadm_id, charttime);
