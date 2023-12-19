-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.rhythm; CREATE TABLE mimiciv_derived.rhythm AS
SELECT
  ce.subject_id,
  ce.charttime,
  MAX(CASE WHEN itemid = 220048 THEN value ELSE NULL END) AS heart_rhythm,
  MAX(CASE WHEN itemid = 224650 THEN value ELSE NULL END) AS ectopy_type,
  MAX(CASE WHEN itemid = 224651 THEN value ELSE NULL END) AS ectopy_frequency,
  MAX(CASE WHEN itemid = 226479 THEN value ELSE NULL END) AS ectopy_type_secondary,
  MAX(CASE WHEN itemid = 226480 THEN value ELSE NULL END) AS ectopy_frequency_secondary
FROM mimiciv_icu.chartevents AS ce
WHERE
  NOT ce.stay_id IS NULL AND ce.itemid IN (220048, 224650, 224651, 226479, 226480)
GROUP BY
  ce.subject_id,
  ce.charttime