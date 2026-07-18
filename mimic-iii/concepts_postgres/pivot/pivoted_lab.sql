-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_lab; CREATE TABLE mimiciii_derived.pivoted_lab AS
/* create a table which has fuzzy boundaries on ICU admission (+- 12 hours from documented time) */ /* this is used to assign icustay_id to lab data, which can be collected outside ICU */ /* involves first creating a lag/lead version of intime/outtime */
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
    i.icustay_id, /* this rule is: */ /*  if there are two ICU stays within 24 hours, set the start/stop */ /*  time as half way between the two ICU stays */
    CASE
      WHEN NOT i.outtime_lag IS NULL AND i.outtime_lag > (
        i.intime - INTERVAL '24' HOUR
      )
      THEN i.intime - CAST(CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('second', i.intime) - DATE_TRUNC('second', i.outtime_lag)) / 1 AS BIGINT) AS DOUBLE PRECISION) / 2 AS BIGINT) * INTERVAL '1' SECOND
      ELSE i.intime - INTERVAL '12' HOUR
    END AS data_start,
    CASE
      WHEN NOT i.intime_lead IS NULL
      AND i.intime_lead < (
        i.outtime + INTERVAL '24' HOUR
      )
      THEN i.outtime + CAST(CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('second', i.intime_lead) - DATE_TRUNC('second', i.outtime)) / 1 AS BIGINT) AS DOUBLE PRECISION) / 2 AS BIGINT) * INTERVAL '1' SECOND
      ELSE (
        i.outtime + INTERVAL '12' HOUR
      )
    END AS data_end
  FROM i
), h /* also create fuzzy boundaries on hospitalization */ AS (
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
    h.hadm_id, /* this rule is: */ /*  if there are two hospitalizations within 24 hours, set the start/stop */ /*  time as half way between the two admissions */
    CASE
      WHEN NOT h.dischtime_lag IS NULL
      AND h.dischtime_lag > (
        h.admittime - INTERVAL '24' HOUR
      )
      THEN h.admittime - CAST(CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('second', h.admittime) - DATE_TRUNC('second', h.dischtime_lag)) / 1 AS BIGINT) AS DOUBLE PRECISION) / 2 AS BIGINT) * INTERVAL '1' SECOND
      ELSE h.admittime - INTERVAL '12' HOUR
    END AS data_start,
    CASE
      WHEN NOT h.admittime_lead IS NULL
      AND h.admittime_lead < (
        h.dischtime + INTERVAL '24' HOUR
      )
      THEN h.dischtime + CAST(CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('second', h.admittime_lead) - DATE_TRUNC('second', h.dischtime)) / 1 AS BIGINT) AS DOUBLE PRECISION) / 2 AS BIGINT) * INTERVAL '1' SECOND
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
    /* begin query that extracts the data */
    SELECT
      le.subject_id,
      le.hadm_id,
      le.charttime, /* here we assign labels to ITEMIDs */ /* this also fuses together multiple ITEMIDs containing the same data */
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
      END AS label, /* add in some sanity checks on the values */
      CASE
        WHEN itemid = 50862 AND valuenum > 10
        THEN NULL /* g/dL 'ALBUMIN' */
        WHEN itemid = 50868 AND valuenum > 10000
        THEN NULL /* mEq/L 'ANION GAP' */
        WHEN itemid = 51144 AND valuenum < 0
        THEN NULL /* immature band forms, % */
        WHEN itemid = 51144 AND valuenum > 100
        THEN NULL /* immature band forms, % */
        WHEN itemid = 50882 AND valuenum > 10000
        THEN NULL /* mEq/L 'BICARBONATE' */
        WHEN itemid = 50885 AND valuenum > 150
        THEN NULL /* mg/dL 'BILIRUBIN' */
        WHEN itemid = 50806 AND valuenum > 10000
        THEN NULL /* mEq/L 'CHLORIDE' */
        WHEN itemid = 50902 AND valuenum > 10000
        THEN NULL /* mEq/L 'CHLORIDE' */
        WHEN itemid = 50912 AND valuenum > 150
        THEN NULL /* mg/dL 'CREATININE' */
        WHEN itemid = 50809 AND valuenum > 10000
        THEN NULL /* mg/dL 'GLUCOSE' */
        WHEN itemid = 50931 AND valuenum > 10000
        THEN NULL /* mg/dL 'GLUCOSE' */
        WHEN itemid = 50810 AND valuenum > 100
        THEN NULL /* % 'HEMATOCRIT' */
        WHEN itemid = 51221 AND valuenum > 100
        THEN NULL /* % 'HEMATOCRIT' */
        WHEN itemid = 50811 AND valuenum > 50
        THEN NULL /* g/dL 'HEMOGLOBIN' */
        WHEN itemid = 51222 AND valuenum > 50
        THEN NULL /* g/dL 'HEMOGLOBIN' */
        WHEN itemid = 50813 AND valuenum > 50
        THEN NULL /* mmol/L 'LACTATE' */
        WHEN itemid = 51265 AND valuenum > 10000
        THEN NULL /* K/uL 'PLATELET' */
        WHEN itemid = 50822 AND valuenum > 30
        THEN NULL /* mEq/L 'POTASSIUM' */
        WHEN itemid = 50971 AND valuenum > 30
        THEN NULL /* mEq/L 'POTASSIUM' */
        WHEN itemid = 51275 AND valuenum > 150
        THEN NULL /* sec 'PTT' */
        WHEN itemid = 51237 AND valuenum > 50
        THEN NULL /* 'INR' */
        WHEN itemid = 51274 AND valuenum > 150
        THEN NULL /* sec 'PT' */
        WHEN itemid = 50824 AND valuenum > 200
        THEN NULL /* mEq/L == mmol/L 'SODIUM' */
        WHEN itemid = 50983 AND valuenum > 200
        THEN NULL /* mEq/L == mmol/L 'SODIUM' */
        WHEN itemid = 51006 AND valuenum > 300
        THEN NULL /* 'BUN' */
        WHEN itemid = 51300 AND valuenum > 1000
        THEN NULL /* 'WBC' */
        WHEN itemid = 51301 AND valuenum > 1000
        THEN NULL /* 'WBC' */
        ELSE valuenum
      END AS valuenum /* the where clause below requires all valuenum to be > 0, so these are only upper limit checks */
    FROM mimiciii.labevents AS le
    WHERE
      le.ITEMID IN (
        50868, /* comment is: LABEL | CATEGORY | FLUID | NUMBER OF ROWS IN LABEVENTS */ /* ANION GAP | CHEMISTRY | BLOOD | 769895 */
        50862, /* ALBUMIN | CHEMISTRY | BLOOD | 146697 */
        51144, /* BANDS - hematology */
        50882, /* BICARBONATE | CHEMISTRY | BLOOD | 780733 */
        50885, /* BILIRUBIN, TOTAL | CHEMISTRY | BLOOD | 238277 */
        50912, /* CREATININE | CHEMISTRY | BLOOD | 797476 */
        50902, /* CHLORIDE | CHEMISTRY | BLOOD | 795568 */
        50931, /* 50806, -- CHLORIDE, WHOLE BLOOD | BLOOD GAS | BLOOD | 48187 */ /* GLUCOSE | CHEMISTRY | BLOOD | 748981 */
        51221, /* 50809, -- GLUCOSE | BLOOD GAS | BLOOD | 196734 */ /* HEMATOCRIT | HEMATOLOGY | BLOOD | 881846 */
        51222, /* 50810, -- HEMATOCRIT, CALCULATED | BLOOD GAS | BLOOD | 89715 */ /* HEMOGLOBIN | HEMATOLOGY | BLOOD | 752523 */
        50813, /* 50811, -- HEMOGLOBIN | BLOOD GAS | BLOOD | 89712 */ /* LACTATE | BLOOD GAS | BLOOD | 187124 */
        51265, /* PLATELET COUNT | HEMATOLOGY | BLOOD | 778444 */
        50971, /* POTASSIUM | CHEMISTRY | BLOOD | 845825 */
        51275, /* 50822, -- POTASSIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 192946 */ /* PTT | HEMATOLOGY | BLOOD | 474937 */
        51237, /* INR(PT) | HEMATOLOGY | BLOOD | 471183 */
        51274, /* PT | HEMATOLOGY | BLOOD | 469090 */
        50983, /* SODIUM | CHEMISTRY | BLOOD | 808489 */
        51006, /* 50824, -- SODIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 71503 */ /* UREA NITROGEN | CHEMISTRY | BLOOD | 791925 */
        51301, /* WHITE BLOOD CELLS | HEMATOLOGY | BLOOD | 753301 */
        51300 /* WBC COUNT | HEMATOLOGY | BLOOD | 2371 */
      )
      AND NOT valuenum IS NULL
      AND valuenum > 0 /* lab values cannot be 0 and cannot be negative */
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