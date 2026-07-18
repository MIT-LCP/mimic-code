-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.echo_data; CREATE TABLE mimiciii_derived.echo_data AS
/* This code extracts structured data from echocardiographies */ /* You can join it to the text notes using ROW_ID */ /* Just note that ROW_ID will differ across versions of MIMIC-III. */
SELECT
  ROW_ID,
  subject_id,
  hadm_id,
  chartdate, /* charttime is always null for echoes.. */ /* however, the time is available in the echo text, e.g.: */ /* , substring(ne.text, 'Date/Time: [\[\]0-9*-]+ at ([0-9:]+)') as TIMESTAMP */ /* we can therefore impute it and re-create charttime */
  CAST(TO_TIMESTAMP(TO_CHAR(CAST(chartdate AS DATE), 'YYYY-MM-DD') || SUBSTRING(ne.text FROM 'Date/Time: .+? at ([0-9]+:[0-9]{2})') || ':00', 'YYYY-MM-DDHH24:MI:SS') AS TIMESTAMP) AS charttime, /* explanation of below substring: */ /*  'Indication: ' - matched verbatim */ /*  (.*?) - match any character */ /*  \n - the end of the line */ /* substring only returns the item in ()s */ /* note: the '?' makes it non-greedy. if you exclude it, it matches until it reaches the *last* \n */
  SUBSTRING(ne.text FROM 'Indication: (.*?)
') AS Indication, /* sometimes numeric values contain de-id text, e.g. [** Numeric Identifier **] */ /* this removes that text */
  CAST(SUBSTRING(ne.text FROM 'Height: \x28in\x29 ([0-9]+)') AS DECIMAL(38, 9)) AS Height,
  CAST(SUBSTRING(ne.text FROM 'Weight \x28lb\x29: ([0-9]+)
') AS DECIMAL(38, 9)) AS Weight,
  CAST(SUBSTRING(ne.text FROM 'BSA \x28m2\x29: ([0-9]+) m2
') AS DECIMAL(38, 9)) AS BSA, /* ends in 'm2' */
  SUBSTRING(ne.text FROM 'BP \x28mm Hg\x29: (.+)
') AS BP, /* Sys/Dias */
  CAST(SUBSTRING(ne.text FROM 'BP \x28mm Hg\x29: ([0-9]+)/[0-9]+?
') AS DECIMAL(38, 9)) AS BPSys, /* first part of fraction */
  CAST(SUBSTRING(ne.text FROM 'BP \x28mm Hg\x29: [0-9]+/([0-9]+?)
') AS DECIMAL(38, 9)) AS BPDias, /* second part of fraction */
  CAST(SUBSTRING(ne.text FROM 'HR \x28bpm\x29: ([0-9]+?)
') AS DECIMAL(38, 9)) AS HR,
  SUBSTRING(ne.text FROM 'Status: (.*?)
') AS Status,
  SUBSTRING(ne.text FROM 'Test: (.*?)
') AS Test,
  SUBSTRING(ne.text FROM 'Doppler: (.*?)
') AS Doppler,
  SUBSTRING(ne.text FROM 'Contrast: (.*?)
') AS Contrast,
  SUBSTRING(ne.text FROM 'Technical Quality: (.*?)
') AS TechnicalQuality
FROM mimiciii.noteevents AS ne
WHERE
  category = 'Echo'