/*
Creates a table with "onset" time of Sepsis-3 in the ICU (MIMIC-III).

Definition (aligned to MIMIC-IV sepsis3):
- Sepsis-3 onset in ICU = earliest time where:
  (1) SOFA_24hours >= 2
  (2) Suspicion of infection exists (SOI event)
  (3) SOFA time is within [-48h, +24h] of suspected_infection_time
Notes:
- Baseline SOFA assumed 0 prior to ICU (same assumption as MIMIC-IV script).
- This defines sepsis-3 onset within ICU only.
*/

DROP TABLE IF EXISTS mimiciii_derived.sepsis3;
CREATE TABLE mimiciii_derived.sepsis3 AS
WITH sofa AS (
  SELECT
    icustay_id,
    starttime,
    endtime,
    respiration_24hours  AS respiration,
    coagulation_24hours  AS coagulation,
    liver_24hours        AS liver,
    cardiovascular_24hours AS cardiovascular,
    cns_24hours          AS cns,
    renal_24hours        AS renal,
    sofa_24hours         AS sofa_score
  FROM mimiciii_derived.pivoted_sofa
  WHERE sofa_24hours >= 2
),
s1 AS (
  SELECT
    ie.subject_id,
    soi.icustay_id,

    -- suspicion_of_infection columns (MIMIC-III version)
    soi.antibiotic_name        AS antibiotic,
    soi.antibiotic_time,
    soi.suspected_infection_time,
    soi.specimen,
    soi.positiveculture        AS positive_culture,

    -- sofa columns
    sofa.starttime,
    sofa.endtime,
    sofa.respiration,
    sofa.coagulation,
    sofa.liver,
    sofa.cardiovascular,
    sofa.cns,
    sofa.renal,
    sofa.sofa_score,

    -- define suspected_infection flag (since MIMIC-III SOI table may not carry it explicitly)
    CASE WHEN soi.suspected_infection_time IS NOT NULL THEN 1 ELSE 0 END AS suspected_infection,

    -- Sepsis-3 flag (same logical form as MIMIC-IV)
    (sofa.sofa_score >= 2 AND soi.suspected_infection_time IS NOT NULL) AS sepsis3,

    -- pick earliest row per icustay
    ROW_NUMBER() OVER (
      PARTITION BY soi.icustay_id
      ORDER BY
        soi.suspected_infection_time NULLS FIRST,
        soi.antibiotic_time NULLS FIRST,
        sofa.endtime NULLS FIRST
    ) AS rn_sus

  FROM mimiciii_derived.suspicion_of_infection AS soi
  INNER JOIN mimiciii_clinical.icustays AS ie
    ON soi.icustay_id = ie.icustay_id
  INNER JOIN sofa
    ON soi.icustay_id = sofa.icustay_id
    AND sofa.endtime >= soi.suspected_infection_time - INTERVAL '48 hour'
    AND sofa.endtime <= soi.suspected_infection_time + INTERVAL '24 hour'

  -- only include rows with a valid SOI time (otherwise the +/- window is meaningless)
  WHERE soi.icustay_id IS NOT NULL
    AND soi.suspected_infection_time IS NOT NULL
)
SELECT
  subject_id,
  icustay_id,

  antibiotic_time,
  suspected_infection_time,

  -- endtime is latest time at which the SOFA score is valid (same as MIMIC-IV)
  endtime AS sofa_time,

  sofa_score,
  respiration,
  coagulation,
  liver,
  cardiovascular,
  cns,
  renal,

  sepsis3
FROM s1
WHERE rn_sus = 1;
