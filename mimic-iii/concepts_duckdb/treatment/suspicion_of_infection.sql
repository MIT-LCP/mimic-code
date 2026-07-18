-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.suspicion_of_infection; CREATE TABLE mimiciii_derived.suspicion_of_infection AS
WITH abx AS (
  SELECT
    pr.hadm_id,
    pr.drug AS antibiotic_name,
    pr.startdate AS antibiotic_time,
    pr.enddate AS antibiotic_endtime
  FROM mimiciii.prescriptions AS pr
  INNER JOIN mimiciii_derived.abx_prescriptions_list AS ab
    ON pr.drug = ab.drug
), ab_tbl AS (
  SELECT
    ie.subject_id,
    ie.hadm_id,
    ie.icustay_id,
    ie.intime,
    ie.outtime,
    abx.antibiotic_name,
    abx.antibiotic_time,
    abx.antibiotic_endtime
  FROM mimiciii.icustays AS ie
  LEFT JOIN abx
    ON ie.hadm_id = abx.hadm_id
), me AS (
  SELECT
    hadm_id,
    chartdate,
    charttime,
    spec_type_desc,
    MAX(CASE WHEN NOT org_name IS NULL AND org_name <> '' THEN 1 ELSE 0 END) AS PositiveCulture
  FROM mimiciii.microbiologyevents
  GROUP BY
    hadm_id,
    chartdate,
    charttime,
    spec_type_desc
), ab_fnl AS (
  SELECT
    ab_tbl.icustay_id,
    ab_tbl.intime,
    ab_tbl.outtime,
    ab_tbl.antibiotic_name,
    ab_tbl.antibiotic_time,
    COALESCE(me72.charttime, me72.chartdate) AS last72_charttime,
    COALESCE(me24.charttime, me24.chartdate) AS next24_charttime,
    me72.positiveculture AS last72_positiveculture,
    me72.spec_type_desc AS last72_specimen,
    me24.positiveculture AS next24_positiveculture,
    me24.spec_type_desc AS next24_specimen
  FROM ab_tbl
  LEFT JOIN me AS me72
    ON ab_tbl.hadm_id = me72.hadm_id
    AND NOT ab_tbl.antibiotic_time IS NULL
    AND (
      (
        ab_tbl.antibiotic_time >= me72.charttime
        AND ab_tbl.antibiotic_time <= me72.charttime + INTERVAL '72' HOUR
      )
      OR (
        me72.charttime IS NULL
        AND ab_tbl.antibiotic_time >= me72.chartdate
        AND ab_tbl.antibiotic_time <= me72.chartdate + INTERVAL '96' HOUR
      )
    )
  LEFT JOIN me AS me24
    ON ab_tbl.hadm_id = me24.hadm_id
    AND NOT ab_tbl.antibiotic_time IS NULL
    AND (
      (
        ab_tbl.antibiotic_time <= me24.charttime
        AND ab_tbl.antibiotic_time >= me24.charttime - INTERVAL '24' HOUR
      )
      OR (
        me24.charttime IS NULL
        AND ab_tbl.antibiotic_time <= me24.chartdate
        AND ab_tbl.antibiotic_time >= me24.chartdate - INTERVAL '24' HOUR
      )
    )
), ab_laststg AS (
  SELECT
    icustay_id,
    antibiotic_name,
    antibiotic_time,
    last72_charttime,
    next24_charttime,
    CASE WHEN COALESCE(last72_charttime, next24_charttime) IS NULL THEN 0 ELSE 1 END AS suspected_infection,
    COALESCE(last72_charttime, next24_charttime) AS suspected_infection_time,
    CASE
      WHEN NOT last72_charttime IS NULL
      THEN last72_specimen
      WHEN NOT next24_charttime IS NULL
      THEN next24_specimen
      ELSE NULL
    END AS specimen,
    CASE
      WHEN NOT last72_charttime IS NULL
      THEN last72_positiveculture
      WHEN NOT next24_charttime IS NULL
      THEN next24_positiveculture
      ELSE NULL
    END AS positiveculture
  FROM ab_fnl
)
SELECT
  icustay_id,
  antibiotic_name,
  antibiotic_time,
  last72_charttime,
  next24_charttime,
  suspected_infection_time,
  specimen,
  positiveculture
FROM ab_laststg
ORDER BY
  icustay_id NULLS FIRST,
  antibiotic_time NULLS FIRST