-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.labs_first_day; CREATE TABLE mimiciii_derived.labs_first_day AS
SELECT
  pvt.subject_id,
  pvt.hadm_id,
  pvt.icustay_id,
  MIN(CASE WHEN label = 'ANION GAP' THEN valuenum ELSE NULL END) AS aniongap_min,
  MAX(CASE WHEN label = 'ANION GAP' THEN valuenum ELSE NULL END) AS aniongap_max,
  MIN(CASE WHEN label = 'ALBUMIN' THEN valuenum ELSE NULL END) AS albumin_min,
  MAX(CASE WHEN label = 'ALBUMIN' THEN valuenum ELSE NULL END) AS albumin_max,
  MIN(CASE WHEN label = 'BANDS' THEN valuenum ELSE NULL END) AS bands_min,
  MAX(CASE WHEN label = 'BANDS' THEN valuenum ELSE NULL END) AS bands_max,
  MIN(CASE WHEN label = 'BICARBONATE' THEN valuenum ELSE NULL END) AS bicarbonate_min,
  MAX(CASE WHEN label = 'BICARBONATE' THEN valuenum ELSE NULL END) AS bicarbonate_max,
  MIN(CASE WHEN label = 'BILIRUBIN' THEN valuenum ELSE NULL END) AS bilirubin_min,
  MAX(CASE WHEN label = 'BILIRUBIN' THEN valuenum ELSE NULL END) AS bilirubin_max,
  MIN(CASE WHEN label = 'CREATININE' THEN valuenum ELSE NULL END) AS creatinine_min,
  MAX(CASE WHEN label = 'CREATININE' THEN valuenum ELSE NULL END) AS creatinine_max,
  MIN(CASE WHEN label = 'CHLORIDE' THEN valuenum ELSE NULL END) AS chloride_min,
  MAX(CASE WHEN label = 'CHLORIDE' THEN valuenum ELSE NULL END) AS chloride_max,
  MIN(CASE WHEN label = 'GLUCOSE' THEN valuenum ELSE NULL END) AS glucose_min,
  MAX(CASE WHEN label = 'GLUCOSE' THEN valuenum ELSE NULL END) AS glucose_max,
  MIN(CASE WHEN label = 'HEMATOCRIT' THEN valuenum ELSE NULL END) AS hematocrit_min,
  MAX(CASE WHEN label = 'HEMATOCRIT' THEN valuenum ELSE NULL END) AS hematocrit_max,
  MIN(CASE WHEN label = 'HEMOGLOBIN' THEN valuenum ELSE NULL END) AS hemoglobin_min,
  MAX(CASE WHEN label = 'HEMOGLOBIN' THEN valuenum ELSE NULL END) AS hemoglobin_max,
  MIN(CASE WHEN label = 'LACTATE' THEN valuenum ELSE NULL END) AS lactate_min,
  MAX(CASE WHEN label = 'LACTATE' THEN valuenum ELSE NULL END) AS lactate_max,
  MIN(CASE WHEN label = 'PLATELET' THEN valuenum ELSE NULL END) AS platelet_min,
  MAX(CASE WHEN label = 'PLATELET' THEN valuenum ELSE NULL END) AS platelet_max,
  MIN(CASE WHEN label = 'POTASSIUM' THEN valuenum ELSE NULL END) AS potassium_min,
  MAX(CASE WHEN label = 'POTASSIUM' THEN valuenum ELSE NULL END) AS potassium_max,
  MIN(CASE WHEN label = 'PTT' THEN valuenum ELSE NULL END) AS ptt_min,
  MAX(CASE WHEN label = 'PTT' THEN valuenum ELSE NULL END) AS ptt_max,
  MIN(CASE WHEN label = 'INR' THEN valuenum ELSE NULL END) AS inr_min,
  MAX(CASE WHEN label = 'INR' THEN valuenum ELSE NULL END) AS inr_max,
  MIN(CASE WHEN label = 'PT' THEN valuenum ELSE NULL END) AS pt_min,
  MAX(CASE WHEN label = 'PT' THEN valuenum ELSE NULL END) AS pt_max,
  MIN(CASE WHEN label = 'SODIUM' THEN valuenum ELSE NULL END) AS sodium_min,
  MAX(CASE WHEN label = 'SODIUM' THEN valuenum ELSE NULL END) AS sodium_max,
  MIN(CASE WHEN label = 'BUN' THEN valuenum ELSE NULL END) AS bun_min,
  MAX(CASE WHEN label = 'BUN' THEN valuenum ELSE NULL END) AS bun_max,
  MIN(CASE WHEN label = 'WBC' THEN valuenum ELSE NULL END) AS wbc_min,
  MAX(CASE WHEN label = 'WBC' THEN valuenum ELSE NULL END) AS wbc_max
FROM (
  SELECT
    ie.subject_id,
    ie.hadm_id,
    ie.icustay_id,
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
      WHEN itemid = 50806
      THEN 'CHLORIDE'
      WHEN itemid = 50902
      THEN 'CHLORIDE'
      WHEN itemid = 50809
      THEN 'GLUCOSE'
      WHEN itemid = 50931
      THEN 'GLUCOSE'
      WHEN itemid = 50810
      THEN 'HEMATOCRIT'
      WHEN itemid = 51221
      THEN 'HEMATOCRIT'
      WHEN itemid = 50811
      THEN 'HEMOGLOBIN'
      WHEN itemid = 51222
      THEN 'HEMOGLOBIN'
      WHEN itemid = 50813
      THEN 'LACTATE'
      WHEN itemid = 51265
      THEN 'PLATELET'
      WHEN itemid = 50822
      THEN 'POTASSIUM'
      WHEN itemid = 50971
      THEN 'POTASSIUM'
      WHEN itemid = 51275
      THEN 'PTT'
      WHEN itemid = 51237
      THEN 'INR'
      WHEN itemid = 51274
      THEN 'PT'
      WHEN itemid = 50824
      THEN 'SODIUM'
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
      ELSE le.valuenum
    END AS valuenum
  FROM mimiciii.icustays AS ie
  LEFT JOIN mimiciii.labevents AS le
    ON le.subject_id = ie.subject_id
    AND le.hadm_id = ie.hadm_id
    AND le.charttime BETWEEN (
      ie.intime - INTERVAL '6' HOUR
    ) AND (
      ie.intime + INTERVAL '1' DAY
    )
    AND le.ITEMID IN (
      50868,
      50862,
      51144,
      50882,
      50885,
      50912,
      50902,
      50806,
      50931,
      50809,
      51221,
      50810,
      51222,
      50811,
      50813,
      51265,
      50971,
      50822,
      51275,
      51237,
      51274,
      50983,
      50824,
      51006,
      51301,
      51300
    )
    AND NOT valuenum IS NULL
    AND valuenum > 0
) AS pvt
GROUP BY
  pvt.subject_id,
  pvt.hadm_id,
  pvt.icustay_id
ORDER BY
  pvt.subject_id NULLS FIRST,
  pvt.hadm_id NULLS FIRST,
  pvt.icustay_id NULLS FIRST