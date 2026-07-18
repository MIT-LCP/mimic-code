-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.ventilation_first_day; CREATE TABLE mimiciii_derived.ventilation_first_day AS
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  MAX(CASE WHEN NOT vd.icustay_id IS NULL THEN 1 ELSE 0 END) AS vent
FROM mimiciii.icustays AS ie
LEFT JOIN mimiciii_derived.ventilation_durations AS vd
  ON ie.icustay_id = vd.icustay_id
  AND (
    (
      vd.starttime <= ie.intime AND vd.endtime >= ie.intime
    )
    OR (
      vd.starttime >= ie.intime AND vd.starttime <= ie.intime + INTERVAL '1' DAY
    )
  )
GROUP BY
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id
ORDER BY
  ie.subject_id NULLS FIRST,
  ie.hadm_id NULLS FIRST,
  ie.icustay_id NULLS FIRST