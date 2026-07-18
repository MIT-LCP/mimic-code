-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.echo_data; CREATE TABLE mimiciii_derived.echo_data AS
SELECT
  ROW_ID,
  subject_id,
  hadm_id,
  chartdate,
  STRPTIME(STRFTIME(CAST(chartdate AS DATE), '%Y-%m-%d') || NULLIF(REGEXP_EXTRACT(ne.text, 'Date/Time: .+? at ([0-9]+:[0-9]{2})', 1), '') || ':00', '%Y-%m-%d%H:%M:%S') AS charttime,
  NULLIF(REGEXP_EXTRACT(ne.text, 'Indication: (.*?)
', 1), '') AS Indication,
  CAST(NULLIF(REGEXP_EXTRACT(ne.text, 'Height: \x28in\x29 ([0-9]+)', 1), '') AS DECIMAL(38, 9)) AS Height,
  CAST(NULLIF(REGEXP_EXTRACT(ne.text, 'Weight \x28lb\x29: ([0-9]+)
', 1), '') AS DECIMAL(38, 9)) AS Weight,
  CAST(NULLIF(REGEXP_EXTRACT(ne.text, 'BSA \x28m2\x29: ([0-9]+) m2
', 1), '') AS DECIMAL(38, 9)) AS BSA,
  NULLIF(REGEXP_EXTRACT(ne.text, 'BP \x28mm Hg\x29: (.+)
', 1), '') AS BP,
  CAST(NULLIF(REGEXP_EXTRACT(ne.text, 'BP \x28mm Hg\x29: ([0-9]+)/[0-9]+?
', 1), '') AS DECIMAL(38, 9)) AS BPSys,
  CAST(NULLIF(REGEXP_EXTRACT(ne.text, 'BP \x28mm Hg\x29: [0-9]+/([0-9]+?)
', 1), '') AS DECIMAL(38, 9)) AS BPDias,
  CAST(NULLIF(REGEXP_EXTRACT(ne.text, 'HR \x28bpm\x29: ([0-9]+?)
', 1), '') AS DECIMAL(38, 9)) AS HR,
  NULLIF(REGEXP_EXTRACT(ne.text, 'Status: (.*?)
', 1), '') AS Status,
  NULLIF(REGEXP_EXTRACT(ne.text, 'Test: (.*?)
', 1), '') AS Test,
  NULLIF(REGEXP_EXTRACT(ne.text, 'Doppler: (.*?)
', 1), '') AS Doppler,
  NULLIF(REGEXP_EXTRACT(ne.text, 'Contrast: (.*?)
', 1), '') AS Contrast,
  NULLIF(REGEXP_EXTRACT(ne.text, 'Technical Quality: (.*?)
', 1), '') AS TechnicalQuality
FROM mimiciii.noteevents AS ne
WHERE
  category = 'Echo'