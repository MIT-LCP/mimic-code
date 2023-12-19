-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.suspicion_of_infection; CREATE TABLE mimiciv_derived.suspicion_of_infection AS
/* note this duplicates prescriptions */ /* each ICU stay in the same hospitalization will get a copy of */ /* all prescriptions for that hospitalization */
WITH ab_tbl AS (
  SELECT
    abx.subject_id,
    abx.hadm_id,
    abx.stay_id,
    abx.antibiotic,
    abx.starttime AS antibiotic_time, /* date is used to match microbiology cultures with only date available */
    DATE_TRUNC('DAY', abx.starttime) AS antibiotic_date,
    abx.stoptime AS antibiotic_stoptime, /* create a unique identifier for each patient antibiotic */
    ROW_NUMBER() OVER (PARTITION BY subject_id ORDER BY starttime NULLS FIRST, stoptime NULLS FIRST, antibiotic NULLS FIRST) AS ab_id
  FROM mimiciv_derived.antibiotic AS abx
), me AS (
  SELECT
    micro_specimen_id, /* the following columns are identical for all rows */ /* of the same micro_specimen_id */ /* these aggregates simply collapse duplicates down to 1 row */
    MAX(subject_id) AS subject_id,
    MAX(hadm_id) AS hadm_id,
    CAST(MAX(chartdate) AS DATE) AS chartdate,
    MAX(charttime) AS charttime,
    MAX(spec_type_desc) AS spec_type_desc, /* identify negative cultures as NULL organism */ /* or a specific itemid saying "NEGATIVE" */
    MAX(
      CASE
        WHEN NOT org_name IS NULL AND org_itemid <> 90856 AND org_name <> ''
        THEN 1
        ELSE 0
      END
    ) AS positiveculture
  FROM mimiciv_hosp.microbiologyevents
  GROUP BY
    micro_specimen_id
), me_then_ab AS (
  SELECT
    ab_tbl.subject_id,
    ab_tbl.hadm_id,
    ab_tbl.stay_id,
    ab_tbl.ab_id,
    me72.micro_specimen_id,
    COALESCE(me72.charttime, CAST(me72.chartdate AS TIMESTAMP)) AS last72_charttime,
    me72.positiveculture AS last72_positiveculture,
    me72.spec_type_desc AS last72_specimen, /* we will use this partition to select the earliest culture */ /* before this abx */ /* this ensures each antibiotic is only matched to a single culture */ /* and consequently we have 1 row per antibiotic */
    ROW_NUMBER() OVER (PARTITION BY ab_tbl.subject_id, ab_tbl.ab_id ORDER BY me72.chartdate NULLS FIRST, me72.charttime) AS micro_seq
  FROM ab_tbl
  /* abx taken after culture, but no more than 72 hours after */
  LEFT JOIN me AS me72
    ON ab_tbl.subject_id = me72.subject_id
    AND (
      (
        NOT me72.charttime IS NULL
        AND ab_tbl.antibiotic_time > me72.charttime
        AND ab_tbl.antibiotic_time <= me72.charttime + INTERVAL '72 HOUR'
      )
      OR (
        me72.charttime IS NULL
        AND antibiotic_date >= me72.chartdate
        AND antibiotic_date <= me72.chartdate + INTERVAL '3 DAY'
      )
    )
), ab_then_me AS (
  SELECT
    ab_tbl.subject_id,
    ab_tbl.hadm_id,
    ab_tbl.stay_id,
    ab_tbl.ab_id,
    me24.micro_specimen_id,
    COALESCE(me24.charttime, CAST(me24.chartdate AS TIMESTAMP)) AS next24_charttime,
    me24.positiveculture AS next24_positiveculture,
    me24.spec_type_desc AS next24_specimen, /* we will use this partition to select the earliest culture */ /* before this abx */ /* this ensures each antibiotic is only matched to a single culture */ /* and consequently we have 1 row per antibiotic */
    ROW_NUMBER() OVER (PARTITION BY ab_tbl.subject_id, ab_tbl.ab_id ORDER BY me24.chartdate NULLS FIRST, me24.charttime) AS micro_seq
  FROM ab_tbl
  /* culture in subsequent 24 hours */
  LEFT JOIN me AS me24
    ON ab_tbl.subject_id = me24.subject_id
    AND (
      (
        NOT me24.charttime IS NULL
        AND ab_tbl.antibiotic_time >= me24.charttime - INTERVAL '24 HOUR' /* noqa: L016 */
        AND ab_tbl.antibiotic_time < me24.charttime
      )
      OR (
        me24.charttime IS NULL
        AND ab_tbl.antibiotic_date >= me24.chartdate - INTERVAL '1 DAY' /* noqa: L016 */
        AND ab_tbl.antibiotic_date <= me24.chartdate
      )
    )
)
SELECT
  ab_tbl.subject_id,
  ab_tbl.stay_id,
  ab_tbl.hadm_id,
  ab_tbl.ab_id,
  ab_tbl.antibiotic,
  ab_tbl.antibiotic_time,
  CASE WHEN last72_specimen IS NULL AND next24_specimen IS NULL THEN 0 ELSE 1 END AS suspected_infection, /* time of suspected infection: */ /*    (1) the culture time (if before antibiotic) */ /*    (2) or the antibiotic time (if before culture) */
  CASE
    WHEN last72_specimen IS NULL AND next24_specimen IS NULL
    THEN NULL
    ELSE COALESCE(last72_charttime, antibiotic_time)
  END AS suspected_infection_time,
  COALESCE(last72_charttime, next24_charttime) AS culture_time, /* the specimen that was cultured */
  COALESCE(last72_specimen, next24_specimen) AS specimen, /* whether the cultured specimen ended up being positive or not */
  COALESCE(last72_positiveculture, next24_positiveculture) AS positive_culture
FROM ab_tbl
LEFT JOIN ab_then_me AS ab2me
  ON ab_tbl.subject_id = ab2me.subject_id
  AND ab_tbl.ab_id = ab2me.ab_id
  AND ab2me.micro_seq = 1
LEFT JOIN me_then_ab AS me2ab
  ON ab_tbl.subject_id = me2ab.subject_id
  AND ab_tbl.ab_id = me2ab.ab_id
  AND me2ab.micro_seq = 1