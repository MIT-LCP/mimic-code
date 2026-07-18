-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.weight_first_day; CREATE TABLE mimiciii_derived.weight_first_day AS
WITH ce AS (
  SELECT
    c.icustay_id,
    AVG(VALUENUM) AS Weight_Admit
  FROM mimiciii.chartevents AS c
  INNER JOIN mimiciii.icustays AS ie
    ON c.icustay_id = ie.icustay_id
    AND c.charttime <= ie.intime + INTERVAL '1' DAY
    AND c.charttime > ie.intime - INTERVAL '1' DAY
  WHERE
    NOT c.valuenum IS NULL
    AND c.itemid IN (762, 226512)
    AND c.valuenum <> 0
    AND (
      c.error IS NULL OR c.error = 0
    )
  GROUP BY
    c.icustay_id
), dwt AS (
  SELECT
    c.icustay_id,
    AVG(VALUENUM) AS Weight_Daily
  FROM mimiciii.chartevents AS c
  INNER JOIN mimiciii.icustays AS ie
    ON c.icustay_id = ie.icustay_id
    AND c.charttime <= ie.intime + INTERVAL '1' DAY
    AND c.charttime > ie.intime - INTERVAL '1' DAY
  WHERE
    NOT c.valuenum IS NULL
    AND c.itemid IN (763, 224639)
    AND c.valuenum <> 0
    AND (
      c.error IS NULL OR c.error = 0
    )
  GROUP BY
    c.icustay_id
), echo_hadm AS (
  SELECT
    ie.icustay_id,
    0.453592 * AVG(weight) AS Weight_EchoInHosp
  FROM mimiciii_derived.echo_data AS ec
  INNER JOIN mimiciii.icustays AS ie
    ON ec.hadm_id = ie.hadm_id AND ec.charttime < ie.intime + INTERVAL '1' DAY
  WHERE
    NOT ec.HADM_ID IS NULL AND NOT ec.weight IS NULL
  GROUP BY
    ie.icustay_id
), echo_nohadm AS (
  SELECT
    ie.icustay_id,
    0.453592 * AVG(weight) AS Weight_EchoPreHosp
  FROM mimiciii_derived.echo_data AS ec
  INNER JOIN mimiciii.icustays AS ie
    ON ie.subject_id = ec.subject_id
    AND ie.intime < ec.charttime + INTERVAL '1' MONTH
    AND ie.intime > ec.charttime
  WHERE
    ec.HADM_ID IS NULL AND NOT ec.weight IS NULL
  GROUP BY
    ie.icustay_id
)
SELECT
  ie.icustay_id,
  ROUND(
    CAST(CASE
      WHEN NOT ce.icustay_id IS NULL
      THEN ce.Weight_Admit
      WHEN NOT dwt.icustay_id IS NULL
      THEN dwt.Weight_Daily
      WHEN NOT eh.icustay_id IS NULL
      THEN eh.Weight_EchoInHosp
      WHEN NOT enh.icustay_id IS NULL
      THEN enh.Weight_EchoPreHosp
      ELSE NULL
    END AS DECIMAL(38, 9)),
    2
  ) AS weight,
  ce.weight_admit,
  dwt.weight_daily,
  eh.weight_echoinhosp,
  enh.weight_echoprehosp
FROM mimiciii.icustays AS ie
INNER JOIN mimiciii.patients AS pat
  ON ie.subject_id = pat.subject_id AND ie.intime > pat.dob + INTERVAL '1' YEAR
LEFT JOIN ce
  ON ie.icustay_id = ce.icustay_id
LEFT JOIN dwt
  ON ie.icustay_id = dwt.icustay_id
LEFT JOIN echo_hadm AS eh
  ON ie.icustay_id = eh.icustay_id
LEFT JOIN echo_nohadm AS enh
  ON ie.icustay_id = enh.icustay_id
ORDER BY
  ie.icustay_id NULLS FIRST