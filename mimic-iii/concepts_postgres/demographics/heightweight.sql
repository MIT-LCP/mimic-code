-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.heightweight; CREATE TABLE mimiciii_derived.heightweight AS
/* ------------------------------------------------------------------ */ /* Title: Extract height and weight for ICUSTAY_IDs */ /* Description: This query gets the first, minimum, and maximum weight and height */ /*        for a single ICUSTAY_ID. It extracts data from the CHARTEVENTS table. */ /* MIMIC version: MIMIC-III v1.4 */ /* ------------------------------------------------------------------ */ /* prep height */
WITH ht_stg AS (
  SELECT
    c.subject_id,
    c.icustay_id,
    c.charttime,
    CASE
      WHEN c.itemid IN (920, 1394, 4187, 3486, 226707)
      THEN CASE
        WHEN c.charttime <= pt.dob + INTERVAL '1' YEAR AND (
          c.valuenum * 2.54
        ) < 80
        THEN c.valuenum * 2.54
        WHEN c.charttime > pt.dob + INTERVAL '1' YEAR
        AND (
          c.valuenum * 2.54
        ) > 120
        AND (
          c.valuenum * 2.54
        ) < 230
        THEN c.valuenum * 2.54
        ELSE NULL
      END
      ELSE CASE
        WHEN c.charttime <= pt.dob + INTERVAL '1' YEAR AND c.valuenum < 80
        THEN c.valuenum
        WHEN c.charttime > pt.dob + INTERVAL '1' YEAR AND c.valuenum > 120 AND c.valuenum < 230
        THEN c.valuenum
        ELSE NULL
      END
    END AS height /* Ensure that all heights are in centimeters, and fix data as needed */
  FROM mimiciii.chartevents AS c
  INNER JOIN mimiciii.patients AS pt
    ON c.subject_id = pt.subject_id
  WHERE
    NOT c.valuenum IS NULL
    AND c.valuenum <> 0
    AND /* exclude rows marked as error */ COALESCE(c.error, 0) = 0
    AND c.itemid IN (
      920, /* CareVue */
      1394,
      4187,
      3486, /* Height inches */
      3485,
      4188, /* Height cm */ /* Metavision */
      226707 /* Height (measured in inches) */
    ) /* note we intentionally ignore the below ITEMID in metavision */ /* these are duplicate data in a different unit */ /* , 226730 -- Height (cm) */
)
SELECT
  ie.icustay_id,
  ROUND(CAST(wt.weight_first AS DECIMAL(38, 9)), 2) AS weight_first,
  ROUND(CAST(wt.weight_min AS DECIMAL(38, 9)), 2) AS weight_min,
  ROUND(CAST(wt.weight_max AS DECIMAL(38, 9)), 2) AS weight_max,
  ROUND(CAST(ht.height_first AS DECIMAL(38, 9)), 2) AS height_first,
  ROUND(CAST(ht.height_min AS DECIMAL(38, 9)), 2) AS height_min,
  ROUND(CAST(ht.height_max AS DECIMAL(38, 9)), 2) AS height_max
FROM mimiciii.icustays AS ie
/* get weight from weight_durations table */
LEFT JOIN (
  SELECT
    icustay_id,
    MIN(CASE WHEN rn = 1 THEN weight ELSE NULL END) AS weight_first,
    MIN(weight) AS weight_min,
    MAX(weight) AS weight_max
  FROM (
    SELECT
      icustay_id,
      weight,
      ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY starttime NULLS FIRST) AS rn
    FROM mimiciii_derived.weight_durations
  ) AS wt_stg
  GROUP BY
    icustay_id
) AS wt
  ON ie.icustay_id = wt.icustay_id
/* get first/min/max height from above, after filtering bad data */
LEFT JOIN (
  SELECT
    icustay_id,
    MIN(CASE WHEN rn = 1 THEN height ELSE NULL END) AS height_first,
    MIN(height) AS height_min,
    MAX(height) AS height_max
  FROM (
    SELECT
      icustay_id,
      height,
      ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY charttime NULLS FIRST) AS rn
    FROM ht_stg
  ) AS ht_stg2
  GROUP BY
    icustay_id
) AS ht
  ON ie.icustay_id = ht.icustay_id
ORDER BY
  icustay_id NULLS FIRST