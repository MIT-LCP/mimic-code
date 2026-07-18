-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.height_first_day; CREATE TABLE mimiciii_derived.height_first_day AS
WITH ce0 AS (
  SELECT
    c.icustay_id,
    CASE WHEN itemid IN (920, 1394, 4187, 3486) THEN valuenum * 2.54 ELSE valuenum END AS Height
  FROM mimiciii.chartevents AS c
  INNER JOIN mimiciii.icustays AS ie
    ON c.icustay_id = ie.icustay_id
    AND c.charttime <= ie.intime + INTERVAL '1' DAY
    AND c.charttime > ie.intime - INTERVAL '1' DAY
  WHERE
    NOT c.valuenum IS NULL
    AND c.itemid IN (226730, 920, 1394, 4187, 3486, 3485, 4188)
    AND c.valuenum <> 0
    AND (
      c.error IS NULL OR c.error = 0
    )
), ce AS (
  SELECT
    icustay_id,
    AVG(height) AS Height_chart
  FROM ce0
  WHERE
    height > 100
  GROUP BY
    icustay_id
), echo AS (
  SELECT
    ec.subject_id,
    2.54 * AVG(height) AS Height_Echo
  FROM mimiciii_derived.echo_data AS ec
  INNER JOIN mimiciii.icustays AS ie
    ON ec.subject_id = ie.subject_id AND ec.charttime < ie.intime + INTERVAL '1' DAY
  WHERE
    NOT height IS NULL AND height * 2.54 > 100
  GROUP BY
    ec.subject_id
)
SELECT
  ie.icustay_id,
  COALESCE(ce.Height_chart, ec.Height_Echo) AS height,
  ce.height_chart,
  ec.height_echo
FROM mimiciii.icustays AS ie
INNER JOIN mimiciii.patients AS pat
  ON ie.subject_id = pat.subject_id AND ie.intime > pat.dob + INTERVAL '1' YEAR
LEFT JOIN ce
  ON ie.icustay_id = ce.icustay_id
LEFT JOIN echo AS ec
  ON ie.subject_id = ec.subject_id