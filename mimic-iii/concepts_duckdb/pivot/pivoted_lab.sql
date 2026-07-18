-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_lab; CREATE TABLE mimiciii_derived.pivoted_lab AS
WITH i AS (
  SELECT
    subject_id,
    icustay_id,
    intime,
    outtime,
    LAG(outtime) OVER (PARTITION BY subject_id ORDER BY intime NULLS FIRST) AS outtime_lag,
    LEAD(intime) OVER (PARTITION BY subject_id ORDER BY intime NULLS FIRST) AS intime_lead
  FROM mimiciii.icustays
), iid_assign AS (
  SELECT
    i.subject_id,
    i.icustay_id,
    CASE
      WHEN NOT i.outtime_lag IS NULL AND i.outtime_lag > (
        i.intime - INTERVAL '24' HOUR
      )
      THEN i.intime - INTERVAL (CAST(DATE_DIFF('SECOND', i.outtime_lag, i.intime) / 2 AS BIGINT)) SECOND
      ELSE i.intime - INTERVAL '12' HOUR
    END AS data_start,
    CASE
      WHEN NOT i.intime_lead IS NULL
      AND i.intime_lead < (
        i.outtime + INTERVAL '24' HOUR
      )
      THEN i.outtime + INTERVAL (CAST(DATE_DIFF('SECOND', i.outtime, i.intime_lead) / 2 AS BIGINT)) SECOND
      ELSE (
        i.outtime + INTERVAL '12' HOUR
      )
    END AS data_end
  FROM i
), h AS (
  SELECT
    subject_id,
    hadm_id,
    admittime,
    dischtime,
    LAG(dischtime) OVER (PARTITION BY subject_id ORDER BY admittime NULLS FIRST) AS dischtime_lag,
    LEAD(admittime) OVER (PARTITION BY subject_id ORDER BY admittime NULLS FIRST) AS admittime_lead
  FROM mimiciii.admissions
), adm AS (
  SELECT
    h.subject_id,
    h.hadm_id,
    CASE
      WHEN NOT h.dischtime_lag IS NULL
      AND h.dischtime_lag > (
        h.admittime - INTERVAL '24' HOUR
      )
      THEN h.admittime - INTERVAL (CAST(DATE_DIFF('SECOND', h.dischtime_lag, h.admittime) / 2 AS BIGINT)) SECOND
      ELSE h.admittime - INTERVAL '12' HOUR
    END AS data_start,
    CASE
      WHEN NOT h.admittime_lead IS NULL
      AND h.admittime_lead < (
        h.dischtime + INTERVAL '24' HOUR
      )
      THEN h.dischtime + INTERVAL (CAST(DATE_DIFF('SECOND', h.dischtime, h.admittime_lead) / 2 AS BIGINT)) SECOND
      ELSE (
        h.dischtime + INTERVAL '12' HOUR
      )
    END AS data_end
  FROM h
), le_avg AS (
  SELECT
    pvt.subject_id,
    pvt.charttime,
    AVG(CASE WHEN label = 'ANION GAP' THEN valuenum ELSE NULL END) AS ANIONGAP,
    AVG(CASE WHEN label = 'ALBUMIN' THEN valuenum ELSE NULL END) AS ALBUMIN,
    AVG(CASE WHEN label = 'BANDS' THEN valuenum ELSE NULL END) AS BANDS,
    AVG(CASE WHEN label = 'BICARBONATE' THEN valuenum ELSE NULL END) AS BICARBONATE,
    AVG(CASE WHEN label = 'BILIRUBIN' THEN valuenum ELSE NULL END) AS BILIRUBIN,
    AVG(CASE WHEN label = 'CREATININE' THEN valuenum ELSE NULL END) AS CREATININE,
    AVG(CASE WHEN label = 'CHLORIDE' THEN valuenum ELSE NULL END) AS CHLORIDE,
    AVG(CASE WHEN label = 'GLUCOSE' THEN valuenum ELSE NULL END) AS GLUCOSE,
    AVG(CASE WHEN label = 'HEMATOCRIT' THEN valuenum ELSE NULL END) AS HEMATOCRIT,
    AVG(CASE WHEN label = 'HEMOGLOBIN' THEN valuenum ELSE NULL END) AS HEMOGLOBIN,
    AVG(CASE WHEN label = 'LACTATE' THEN valuenum ELSE NULL END) AS LACTATE,
    AVG(CASE WHEN label = 'PLATELET' THEN valuenum ELSE NULL END) AS PLATELET,
    AVG(CASE WHEN label = 'POTASSIUM' THEN valuenum ELSE NULL END) AS POTASSIUM,
    AVG(CASE WHEN label = 'PTT' THEN valuenum ELSE NULL END) AS PTT,
    AVG(CASE WHEN label = 'INR' THEN valuenum ELSE NULL END) AS INR,
    AVG(CASE WHEN label = 'PT' THEN valuenum ELSE NULL END) AS PT,
    AVG(CASE WHEN label = 'SODIUM' THEN valuenum ELSE NULL END) AS SODIUM,
    AVG(CASE WHEN label = 'BUN' THEN valuenum ELSE NULL END) AS BUN,
    AVG(CASE WHEN label = 'WBC' THEN valuenum ELSE NULL END) AS WBC
  FROM (
    SELECT
      le.subject_id,
      le.hadm_id,
      le.charttime,
      CASE
        WHEN itemid = 50868
        THEN 'ANION GAP'
        WHEN itemid = 50862
        THEN 'ALBUMIN'
        WHEN itemid = 51144
        THEN 'BANDS'
        WHEN itemid = 50882
        THEN 'BICARBONATE'
        WHEN itemid = 50885
        THEN 'BILIRUBIN'
        WHEN itemid = 50912
        THEN 'CREATININE'
        WHEN itemid = 50902
        THEN 'CHLORIDE'
        WHEN itemid = 50931
        THEN 'GLUCOSE'
        WHEN itemid = 51221
        THEN 'HEMATOCRIT'
        WHEN itemid = 51222
        THEN 'HEMOGLOBIN'
        WHEN itemid = 50813
        THEN 'LACTATE'
        WHEN itemid = 51265
        THEN 'PLATELET'
        WHEN itemid = 50971
        THEN 'POTASSIUM'
        WHEN itemid = 51275
        THEN 'PTT'
        WHEN itemid = 51237
        THEN 'INR'
        WHEN itemid = 51274
        THEN 'PT'
        WHEN itemid = 50983
        THEN 'SODIUM'
        WHEN itemid = 51006
        THEN 'BUN'
        WHEN itemid = 51300
        THEN 'WBC'
        WHEN itemid = 51301
        THEN 'WBC'
        ELSE NULL
      END AS label,
      CASE
        WHEN itemid = 50862 AND valuenum > 10
        THEN NULL
        WHEN itemid = 50868 AND valuenum > 10000
        THEN NULL
        WHEN itemid = 51144 AND valuenum < 0
        THEN NULL
        WHEN itemid = 51144 AND valuenum > 100
        THEN NULL
        WHEN itemid = 50882 AND valuenum > 10000
        THEN NULL
        WHEN itemid = 50885 AND valuenum > 150
        THEN NULL
        WHEN itemid = 50806 AND valuenum > 10000
        THEN NULL
        WHEN itemid = 50902 AND valuenum > 10000
        THEN NULL
        WHEN itemid = 50912 AND valuenum > 150
        THEN NULL
        WHEN itemid = 50809 AND valuenum > 10000
        THEN NULL
        WHEN itemid = 50931 AND valuenum > 10000
        THEN NULL
        WHEN itemid = 50810 AND valuenum > 100
        THEN NULL
        WHEN itemid = 51221 AND valuenum > 100
        THEN NULL
        WHEN itemid = 50811 AND valuenum > 50
        THEN NULL
        WHEN itemid = 51222 AND valuenum > 50
        THEN NULL
        WHEN itemid = 50813 AND valuenum > 50
        THEN NULL
        WHEN itemid = 51265 AND valuenum > 10000
        THEN NULL
        WHEN itemid = 50822 AND valuenum > 30
        THEN NULL
        WHEN itemid = 50971 AND valuenum > 30
        THEN NULL
        WHEN itemid = 51275 AND valuenum > 150
        THEN NULL
        WHEN itemid = 51237 AND valuenum > 50
        THEN NULL
        WHEN itemid = 51274 AND valuenum > 150
        THEN NULL
        WHEN itemid = 50824 AND valuenum > 200
        THEN NULL
        WHEN itemid = 50983 AND valuenum > 200
        THEN NULL
        WHEN itemid = 51006 AND valuenum > 300
        THEN NULL
        WHEN itemid = 51300 AND valuenum > 1000
        THEN NULL
        WHEN itemid = 51301 AND valuenum > 1000
        THEN NULL
        ELSE valuenum
      END AS valuenum
    FROM mimiciii.labevents AS le
    WHERE
      le.ITEMID IN (
        50868,
        50862,
        51144,
        50882,
        50885,
        50912,
        50902,
        50931,
        51221,
        51222,
        50813,
        51265,
        50971,
        51275,
        51237,
        51274,
        50983,
        51006,
        51301,
        51300
      )
      AND NOT valuenum IS NULL
      AND valuenum > 0
  ) AS pvt
  GROUP BY
    pvt.subject_id,
    pvt.charttime
)
SELECT
  iid.icustay_id,
  adm.hadm_id,
  le_avg.*
FROM le_avg
LEFT JOIN adm
  ON le_avg.subject_id = adm.subject_id
  AND le_avg.charttime >= adm.data_start
  AND le_avg.charttime < adm.data_end
LEFT JOIN iid_assign AS iid
  ON le_avg.subject_id = iid.subject_id
  AND le_avg.charttime >= iid.data_start
  AND le_avg.charttime < iid.data_end
ORDER BY
  le_avg.subject_id NULLS FIRST,
  le_avg.charttime NULLS FIRST