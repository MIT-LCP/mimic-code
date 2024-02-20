-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.first_day_vitalsign; CREATE TABLE mimiciv_derived.first_day_vitalsign AS
SELECT
  ie.subject_id,
  ie.stay_id,
  MIN(heart_rate) AS heart_rate_min,
  MAX(heart_rate) AS heart_rate_max,
  AVG(heart_rate) AS heart_rate_mean,
  MIN(sbp) AS sbp_min,
  MAX(sbp) AS sbp_max,
  AVG(sbp) AS sbp_mean,
  MIN(dbp) AS dbp_min,
  MAX(dbp) AS dbp_max,
  AVG(dbp) AS dbp_mean,
  MIN(mbp) AS mbp_min,
  MAX(mbp) AS mbp_max,
  AVG(mbp) AS mbp_mean,
  MIN(resp_rate) AS resp_rate_min,
  MAX(resp_rate) AS resp_rate_max,
  AVG(resp_rate) AS resp_rate_mean,
  MIN(temperature) AS temperature_min,
  MAX(temperature) AS temperature_max,
  AVG(temperature) AS temperature_mean,
  MIN(spo2) AS spo2_min,
  MAX(spo2) AS spo2_max,
  AVG(spo2) AS spo2_mean,
  MIN(glucose) AS glucose_min,
  MAX(glucose) AS glucose_max,
  AVG(glucose) AS glucose_mean
FROM mimiciv_icu.icustays AS ie
LEFT JOIN mimiciv_derived.vitalsign AS ce
  ON ie.stay_id = ce.stay_id
  AND ce.charttime >= ie.intime - INTERVAL '6' HOUR
  AND ce.charttime <= ie.intime + INTERVAL '1' DAY
GROUP BY
  ie.subject_id,
  ie.stay_id