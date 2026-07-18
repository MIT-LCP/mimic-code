-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_height; CREATE TABLE mimiciii_derived.pivoted_height AS
/* prep height */
WITH ht_in AS (
  SELECT
    c.subject_id,
    c.icustay_id,
    c.charttime,
    ROUND(CAST(CASE
      WHEN c.itemid IN (920, 1394, 4187, 3486, 226707)
      THEN ROUND(CAST(c.valuenum * 2.54 AS NUMERIC), 2)
      ELSE c.valuenum
    END AS NUMERIC), 2) AS height, /* Ensure that all heights are in centimeters */
    c.valuenum AS height_orig
  FROM mimiciii.chartevents AS c
  WHERE
    NOT c.valuenum IS NULL
    AND c.valuenum <> 0
    AND /* exclude rows marked as error */ COALESCE(c.error, 0) = 0
    AND /* Height (measured in inches) */ c.itemid IN (920, /* CareVue */1394, 4187, 3486, /* Metavision */226707)
), ht_cm AS (
  SELECT
    c.subject_id,
    c.icustay_id,
    c.charttime,
    ROUND(CAST(CASE
      WHEN c.itemid IN (920, 1394, 4187, 3486, 226707)
      THEN c.valuenum * 2.54
      ELSE c.valuenum
    END AS NUMERIC), 2) AS height /* Ensure that all heights are in centimeters */
  FROM mimiciii.chartevents AS c
  WHERE
    NOT c.valuenum IS NULL
    AND c.valuenum <> 0
    AND /* exclude rows marked as error */ COALESCE(c.error, 0) = 0
    AND /* Height cm */ c.itemid IN (3485, /* CareVue */4188, /* MetaVision */226730)
), ht_stg0 /* merge cm/height, only take 1 value per charted row */ AS (
  SELECT
    COALESCE(h1.subject_id, h2.subject_id) AS subject_id,
    COALESCE(h1.charttime, h2.charttime) AS charttime,
    COALESCE(h1.height, h2.height) AS height
  FROM ht_cm AS h1
  FULL OUTER JOIN ht_in AS h2
    ON h1.subject_id = h2.subject_id AND h1.charttime = h2.charttime
), ht_stg1 /* filter out bad heights */ AS (
  SELECT
    h.subject_id,
    charttime,
    CASE
      WHEN CAST(EXTRACT(YEAR FROM charttime) - EXTRACT(YEAR FROM pt.dob) AS BIGINT) <= 1
      AND height < 80
      THEN height
      WHEN CAST(EXTRACT(YEAR FROM charttime) - EXTRACT(YEAR FROM pt.dob) AS BIGINT) > 1
      AND height > 120
      AND height < 230
      THEN height
      ELSE NULL
    END AS height
  FROM ht_stg0 AS h
  INNER JOIN mimiciii.patients AS pt
    ON h.subject_id = pt.subject_id
), echo_note /* heights from echo-cardiography notes */ AS (
  SELECT
    subject_id, /* extract the time of the note from the text itself */ /* add this to the structured date in the chartdate column */
    CAST(TO_TIMESTAMP(TO_CHAR(CAST(chartdate AS DATE), 'TMMon-DD-YYYY') || SUBSTRING(ne.text FROM 'Date/Time: [\[\]0-9*-]+ at ([0-9:]+)'), 'TMMon-DD-YYYYHH24:MI') AS TIMESTAMP) AS charttime, /* sometimes numeric values contain de-id numbers, e.g. [** Numeric Identifier **] */ /* this case is used to ignore that text */
    CASE
      WHEN SUBSTRING(ne.text FROM 'Height: \(in\) (.*?)
') LIKE '%*%'
      THEN NULL
      ELSE CAST(SUBSTRING(ne.text FROM 'Height: \(in\) (.*?)
') AS DECIMAL(38, 9))
    END * 2.54 AS height
  FROM mimiciii.noteevents AS ne
  WHERE
    ne.category = 'Echo'
), ibw_note /* use documented ideal body weights to back-calculate height */ AS (
  SELECT
    subject_id,
    ne.category,
    charttime,
    CAST(SUBSTRING(text FROM 'Ideal body weight: ([0-9]+\.?[0-9]*)') AS DECIMAL(38, 9)) AS ibw
  FROM mimiciii.noteevents AS ne
  WHERE
    text LIKE '%Ideal body weight:%' AND ne.category <> 'Echo'
), ht_from_ibw AS (
  /* IBW formulas */ /* inches */ /* F:  IBW = 45.5 kg + 2.3 kg * (height in inches - 60) */ /* M:  IBW = 50 kg + 2.3 kg * (height in inches - 60) */ /* cm */ /* F: 45.5 + (0.91 × [height in centimeters − 152.4]) */ /* M: 50 + (0.91 × [height in centimeters − 152.4]) */
  SELECT
    ne.subject_id,
    charttime,
    CASE
      WHEN gender = 'F'
      THEN CAST((
        ibw - 45.5
      ) AS DOUBLE PRECISION) / 0.91 + 152.4
      ELSE CAST((
        ibw - 50
      ) AS DOUBLE PRECISION) / 0.91 + 152.4
    END AS height
  FROM ibw_note AS ne
  INNER JOIN mimiciii.patients AS pt
    ON ne.subject_id = pt.subject_id
  WHERE
    NOT ibw IS NULL AND ibw <> 0
), ht_nutrition AS (
  /* nutrition notes usually only document height */ /* but the original note formatting has been lost, so we can't do a clever regex */ /* instead, we just look for the unit of measure (cm) */
  SELECT
    subject_id,
    charttime,
    CAST(SUBSTRING(ne.text FROM '([0-9]+) cm') AS DECIMAL(38, 9)) AS height
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
  'noteevents - nutrition' AS source, /* convert the heights */
  CASE WHEN height < 80 THEN height * 2.54 ELSE height END AS height
FROM ht_nutrition
WHERE
  NOT height IS NULL AND height > 0
ORDER BY
  subject_id NULLS FIRST,
  charttime NULLS FIRST,
  source NULLS FIRST,
  height NULLS FIRST