-- prep height
WITH ht_in AS
(
  SELECT 
    c.subject_id, c.icustay_id, c.charttime,
    -- Ensure that all heights are in centimeters
    ROUND(CASE
      WHEN c.itemid IN (920, 1394, 4187, 3486, 226707)
        THEN ROUND(c.valuenum * 2.54, 2)
      ELSE c.valuenum
    END, 2) AS height
    , c.valuenum as height_orig
  FROM `physionet-data.mimiciii_clinical.chartevents` c
  WHERE c.valuenum IS NOT NULL
  AND c.valuenum != 0
  -- exclude rows marked as error
  AND COALESCE(c.error, 0) = 0
  -- Height (measured in inches)
  AND c.itemid IN
  (
    -- CareVue
    920, 1394, 4187, 3486
    -- Metavision
    , 226707
  )
)
, ht_cm AS
(
  SELECT 
    c.subject_id, c.icustay_id, c.charttime,
    -- Ensure that all heights are in centimeters
    ROUND(CASE
      WHEN c.itemid IN (920, 1394, 4187, 3486, 226707)
        THEN c.valuenum * 2.54
      ELSE c.valuenum
    END, 2) AS height
  FROM `physionet-data.mimiciii_clinical.chartevents` c
  WHERE c.valuenum IS NOT NULL
  AND c.valuenum != 0
  -- exclude rows marked as error
  AND COALESCE(c.error, 0) = 0
  -- Height cm
  AND c.itemid IN
  (
    -- CareVue
    3485, 4188
    -- MetaVision
    , 226730
  )
)
-- merge cm/height, only take 1 value per charted row
, ht_stg0 AS
(
  SELECT
  COALESCE(h1.subject_id, h1.subject_id) as subject_id
  , COALESCE(h1.charttime, h1.charttime) AS charttime
  , COALESCE(h1.height, h2.height) as height
  FROM ht_cm h1
  FULL OUTER JOIN ht_in h2
    ON h1.subject_id = h2.subject_id
    AND h1.charttime = h2.charttime
)
-- filter out bad heights
, ht_stg1 AS
(
  SELECT
    h.subject_id
    , charttime
    , CASE
        -- rule for neonates
        WHEN DATETIME_DIFF(charttime, pt.dob, YEAR) <= 1 AND height < 80 THEN height
        -- rule for adults
        WHEN DATETIME_DIFF(charttime, pt.dob, YEAR) > 1 AND height > 120 AND height < 230 THEN height
      ELSE NULL END as height
  FROM ht_stg0 h
  INNER JOIN `physionet-data.mimiciii_clinical.patients` pt
    ON h.subject_id = pt.subject_id
)
-- heights from echo-cardiography notes
, echo_note AS
(
  SELECT
    subject_id
    -- extract the time of the note from the text itself
    -- add this to the structured date in the chartdate column
    , PARSE_DATETIME('%b-%d-%Y%H:%M',
      CONCAT(
        FORMAT_DATE("%b-%d-%Y", chartdate),
        REGEXP_EXTRACT(ne.text, 'Date/Time: [\\[\\]0-9*-]+ at ([0-9:]+)')
       )
    ) AS charttime
    -- sometimes numeric values contain de-id numbers, e.g. [** Numeric Identifier **]
    -- this case is used to ignore that text
    , case
        when REGEXP_EXTRACT(ne.text, 'Height: \\(in\\) (.*?)\n') like '%*%'
            then null
        else cast(REGEXP_EXTRACT(ne.text, 'Height: \\(in\\) (.*?)\n') as numeric)
        end * 2.54 as height
  FROM `physionet-data.mimiciii_notes.noteevents` ne
  WHERE ne.category = 'Echo'
)
-- use documented ideal body weights to back-calculate height
, ibw_note AS
(
    SELECT subject_id
    , ne.category
    , charttime
    , CAST(REGEXP_EXTRACT(text, 'Ideal body weight: ([0-9]+\\.?[0-9]*)') AS NUMERIC) as ibw
    FROM `physionet-data.mimiciii_notes.noteevents` ne
    WHERE text like '%Ideal body weight:%'
    AND ne.category != 'Echo'
)
, ht_from_ibw AS
(
    -- IBW formulas
    -- inches
    -- F:  IBW = 45.5 kg + 2.3 kg * (height in inches - 60)
    -- M:  IBW = 50 kg + 2.3 kg * (height in inches - 60)
    
    -- cm
    -- F: 45.5 + (0.91 × [height in centimeters − 152.4])
    -- M: 50 + (0.91 × [height in centimeters − 152.4])
    
    SELECT ne.subject_id
    , charttime
    , CASE
        WHEN gender = 'F' THEN (ibw - 45.5)/0.91 + 152.4
        ELSE (ibw - 50)/0.91 + 152.4 END AS height
    FROM ibw_note ne
    INNER JOIN `physionet-data.mimiciii_clinical.patients` pt
      ON ne.subject_id = pt.subject_id
    WHERE ibw IS NOT NULL AND ibw != 0
)
, ht_nutrition AS
(
    -- nutrition notes usually only document height
    -- but the original note formatting has been lost, so we can't do a clever regex
    -- instead, we just look for the unit of measure (cm)
    SELECT subject_id
    , charttime
    , CAST(REGEXP_EXTRACT(ne.text, '([0-9]+) cm') AS NUMERIC) as height
    FROM `physionet-data.mimiciii_notes.noteevents` ne
    WHERE category = 'Nutrition'
    AND lower(text) like '%height%'
)
SELECT subject_id, charttime, 'chartevents' as source, height
FROM ht_stg1
WHERE height IS NOT NULL AND height > 0
UNION ALL
SELECT subject_id, charttime, 'noteevents - echo' as source, height
FROM echo_note
WHERE height IS NOT NULL AND height > 0
UNION ALL
SELECT subject_id, charttime, 'noteevents - ibw' as source, height
FROM ht_from_ibw
WHERE height IS NOT NULL AND height > 0
UNION ALL
SELECT subject_id, charttime, 'noteevents - nutrition' as source
-- convert the heights
    , CASE 
        WHEN height < 80 THEN height*2.54
        ELSE height
    END AS height
FROM ht_nutrition
WHERE height IS NOT NULL AND height > 0
ORDER BY subject_id, charttime, source, height;