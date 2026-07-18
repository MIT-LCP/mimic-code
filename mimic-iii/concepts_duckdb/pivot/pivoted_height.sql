-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_height; CREATE TABLE mimiciii_derived.pivoted_height AS
WITH ht_in AS (
  SELECT
    c.subject_id,
    c.icustay_id,
    c.charttime,
    ROUND(
      CASE
        WHEN c.itemid IN (920, 1394, 4187, 3486, 226707)
        THEN ROUND(c.valuenum * 2.54, 2)
        ELSE c.valuenum
      END,
      2
    ) AS height,
    c.valuenum AS height_orig
  FROM mimiciii.chartevents AS c
  WHERE
    NOT c.valuenum IS NULL
    AND c.valuenum <> 0
    AND COALESCE(c.error, 0) = 0
    AND c.itemid IN (920, 1394, 4187, 3486, 226707)
), ht_cm AS (
  SELECT
    c.subject_id,
    c.icustay_id,
    c.charttime,
    ROUND(
      CASE
        WHEN c.itemid IN (920, 1394, 4187, 3486, 226707)
        THEN c.valuenum * 2.54
        ELSE c.valuenum
      END,
      2
    ) AS height
  FROM mimiciii.chartevents AS c
  WHERE
    NOT c.valuenum IS NULL
    AND c.valuenum <> 0
    AND COALESCE(c.error, 0) = 0
    AND c.itemid IN (3485, 4188, 226730)
), ht_stg0 AS (
  SELECT
    COALESCE(h1.subject_id, h2.subject_id) AS subject_id,
    COALESCE(h1.charttime, h2.charttime) AS charttime,
    COALESCE(h1.height, h2.height) AS height
  FROM ht_cm AS h1
  FULL OUTER JOIN ht_in AS h2
    ON h1.subject_id = h2.subject_id AND h1.charttime = h2.charttime
), ht_stg1 AS (
  SELECT
    h.subject_id,
    charttime,
    CASE
      WHEN DATE_DIFF('YEAR', pt.dob, charttime) <= 1 AND height < 80
      THEN height
      WHEN DATE_DIFF('YEAR', pt.dob, charttime) > 1 AND height > 120 AND height < 230
      THEN height
      ELSE NULL
    END AS height
  FROM ht_stg0 AS h
  INNER JOIN mimiciii.patients AS pt
    ON h.subject_id = pt.subject_id
), echo_note AS (
  SELECT
    subject_id,
    STRPTIME(STRFTIME(CAST(chartdate AS DATE), '%b-%d-%Y') || NULLIF(REGEXP_EXTRACT(ne.text, 'Date/Time: [\[\]0-9*-]+ at ([0-9:]+)', 1), ''), '%b-%d-%Y%H:%M') AS charttime,
    CASE
      WHEN NULLIF(REGEXP_EXTRACT(ne.text, 'Height: \(in\) (.*?)
', 1), '') LIKE '%*%'
      THEN NULL
      ELSE CAST(NULLIF(REGEXP_EXTRACT(ne.text, 'Height: \(in\) (.*?)
', 1), '') AS DECIMAL(38, 9))
    END * 2.54 AS height
  FROM mimiciii.noteevents AS ne
  WHERE
    ne.category = 'Echo'
), ibw_note AS (
  SELECT
    subject_id,
    ne.category,
    charttime,
    CAST(NULLIF(REGEXP_EXTRACT(text, 'Ideal body weight: ([0-9]+\.?[0-9]*)', 1), '') AS DECIMAL(38, 9)) AS ibw
  FROM mimiciii.noteevents AS ne
  WHERE
    text LIKE '%Ideal body weight:%' AND ne.category <> 'Echo'
), ht_from_ibw AS (
  SELECT
    ne.subject_id,
    charttime,
    CASE
      WHEN gender = 'F'
      THEN (
        ibw - 45.5
      ) / 0.91 + 152.4
      ELSE (
        ibw - 50
      ) / 0.91 + 152.4
    END AS height
  FROM ibw_note AS ne
  INNER JOIN mimiciii.patients AS pt
    ON ne.subject_id = pt.subject_id
  WHERE
    NOT ibw IS NULL AND ibw <> 0
), ht_nutrition AS (
  SELECT
    subject_id,
    charttime,
    CAST(NULLIF(REGEXP_EXTRACT(ne.text, '([0-9]+) cm', 1), '') AS DECIMAL(38, 9)) AS height
  FROM mimiciii.noteevents AS ne
  WHERE
    category = 'Nutrition' AND LOWER(text) LIKE '%height%'
)
SELECT
  subject_id,
  charttime,
  'chartevents' AS source,
  height
FROM ht_stg1
WHERE
  NOT height IS NULL AND height > 0
UNION ALL
SELECT
  subject_id,
  charttime,
  'noteevents - echo' AS source,
  height
FROM echo_note
WHERE
  NOT height IS NULL AND height > 0
UNION ALL
SELECT
  subject_id,
  charttime,
  'noteevents - ibw' AS source,
  height
FROM ht_from_ibw
WHERE
  NOT height IS NULL AND height > 0
UNION ALL
SELECT
  subject_id,
  charttime,
  'noteevents - nutrition' AS source,
  CASE WHEN height < 80 THEN height * 2.54 ELSE height END AS height
FROM ht_nutrition
WHERE
  NOT height IS NULL AND height > 0
ORDER BY
  subject_id NULLS FIRST,
  charttime NULLS FIRST,
  source NULLS FIRST,
  height NULLS FIRST