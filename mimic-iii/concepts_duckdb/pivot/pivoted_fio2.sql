-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_fio2; CREATE TABLE mimiciii_derived.pivoted_fio2 AS
WITH pvt AS (
  SELECT
    le.hadm_id,
    le.charttime,
    ROUND(
      MAX(
        CASE
          WHEN valuenum <= 0
          THEN NULL
          WHEN itemid = 50816 AND valuenum < 20
          THEN NULL
          WHEN itemid = 50816 AND valuenum > 100
          THEN NULL
          ELSE valuenum
        END
      ),
      2
    ) AS valuenum
  FROM mimiciii.labevents AS le
  WHERE
    le.ITEMID = 50816
  GROUP BY
    le.hadm_id,
    le.charttime
), stg_fio2 AS (
  SELECT
    hadm_id,
    charttime,
    ROUND(
      MAX(
        CASE
          WHEN itemid = 223835
          THEN CASE
            WHEN valuenum > 0 AND valuenum <= 1
            THEN valuenum * 100
            WHEN valuenum > 1 AND valuenum < 21
            THEN NULL
            WHEN valuenum >= 21 AND valuenum <= 100
            THEN valuenum
            ELSE NULL
          END
          WHEN itemid IN (3420, 3422)
          THEN valuenum
          WHEN itemid = 190 AND valuenum > 0.20 AND valuenum < 1
          THEN valuenum * 100
          ELSE NULL
        END
      ),
      2
    ) AS fio2_chartevents
  FROM mimiciii.chartevents
  WHERE
    ITEMID IN (3420, 190, 223835, 3422)
    AND valuenum > 0
    AND valuenum < 100
    AND (
      error IS NULL OR error <> 1
    )
  GROUP BY
    hadm_id,
    charttime
)
SELECT
  ie.icustay_id,
  COALESCE(pvt.charttime, fi.charttime) AS charttime,
  COALESCE(pvt.valuenum, fi.fio2_chartevents) AS fio2
FROM (
  SELECT
    hadm_id,
    charttime
  FROM pvt
  UNION
  SELECT
    hadm_id,
    charttime
  FROM stg_fio2
) AS base
INNER JOIN mimiciii.icustays AS ie
  ON base.hadm_id = ie.hadm_id
  AND base.charttime >= ie.intime - INTERVAL '12' HOUR
  AND base.charttime <= ie.outtime + INTERVAL '12' HOUR
LEFT JOIN pvt
  ON base.hadm_id = pvt.hadm_id AND base.charttime = pvt.charttime
LEFT JOIN stg_fio2 AS fi
  ON base.hadm_id = fi.hadm_id AND base.charttime = fi.charttime
ORDER BY
  icustay_id NULLS FIRST,
  charttime NULLS FIRST