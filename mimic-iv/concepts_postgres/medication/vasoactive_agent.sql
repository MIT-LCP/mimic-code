-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.vasoactive_agent; CREATE TABLE mimiciv_derived.vasoactive_agent AS
/* left join to raw data tables to combine doses */
/* This query creates a single table with ongoing doses of vasoactive agents. */ /* TBD: rarely angiotensin II, methylene blue, and */ /* isoprenaline/isoproterenol are used. These are not in the query currently */ /* as they are not documented in MetaVision. However, they could */ /* be documented in other hospital wide systems. */ /* collect all vasopressor administration times */ /* create a single table with these as start/stop times */
WITH tm AS (
  SELECT
    stay_id,
    starttime AS vasotime
  FROM mimiciv_derived.dobutamine
  UNION
  SELECT
    stay_id,
    starttime AS vasotime
  FROM mimiciv_derived.dopamine
  UNION
  SELECT
    stay_id,
    starttime AS vasotime
  FROM mimiciv_derived.epinephrine
  UNION
  SELECT
    stay_id,
    starttime AS vasotime
  FROM mimiciv_derived.norepinephrine
  UNION
  SELECT
    stay_id,
    starttime AS vasotime
  FROM mimiciv_derived.phenylephrine
  UNION
  SELECT
    stay_id,
    starttime AS vasotime
  FROM mimiciv_derived.vasopressin
  UNION
  SELECT
    stay_id,
    starttime AS vasotime
  FROM mimiciv_derived.milrinone
  UNION
  /* combine end times from the same tables */
  SELECT
    stay_id,
    endtime AS vasotime
  FROM mimiciv_derived.dobutamine
  UNION
  SELECT
    stay_id,
    endtime AS vasotime
  FROM mimiciv_derived.dopamine
  UNION
  SELECT
    stay_id,
    endtime AS vasotime
  FROM mimiciv_derived.epinephrine
  UNION
  SELECT
    stay_id,
    endtime AS vasotime
  FROM mimiciv_derived.norepinephrine
  UNION
  SELECT
    stay_id,
    endtime AS vasotime
  FROM mimiciv_derived.phenylephrine
  UNION
  SELECT
    stay_id,
    endtime AS vasotime
  FROM mimiciv_derived.vasopressin
  UNION
  SELECT
    stay_id,
    endtime AS vasotime
  FROM mimiciv_derived.milrinone
), tm_lag AS (
  SELECT
    stay_id,
    vasotime AS starttime, /* note: the last row for each partition (stay_id) will have */ /* a NULL endtime. we can drop this row later, as we know that no */ /* vasopressor will start at this time (otherwise, we would have */ /* a later end time, which would mean it's not the last row!) */
    LEAD(vasotime, 1) OVER (PARTITION BY stay_id ORDER BY vasotime NULLS FIRST) AS endtime
  FROM tm
)
SELECT
  t.stay_id,
  t.starttime,
  t.endtime, /* inopressors/vasopressors */
  dop.vaso_rate AS dopamine, /* mcg/kg/min */
  epi.vaso_rate AS epinephrine, /* mcg/kg/min */
  nor.vaso_rate AS norepinephrine, /* mcg/kg/min */
  phe.vaso_rate AS phenylephrine, /* mcg/kg/min */
  vas.vaso_rate AS vasopressin, /* units/hour */ /* inodialators */
  dob.vaso_rate AS dobutamine, /* mcg/kg/min */
  mil.vaso_rate AS milrinone /* mcg/kg/min */
/* isoproterenol is used in CCU/CVICU but not in metavision */ /* other drugs not included here but (rarely) used in the BIDMC: */ /* angiotensin II, methylene blue */
FROM tm_lag AS t
LEFT JOIN mimiciv_derived.dobutamine AS dob
  ON t.stay_id = dob.stay_id
  AND t.starttime >= dob.starttime
  AND t.endtime <= dob.endtime
LEFT JOIN mimiciv_derived.dopamine AS dop
  ON t.stay_id = dop.stay_id
  AND t.starttime >= dop.starttime
  AND t.endtime <= dop.endtime
LEFT JOIN mimiciv_derived.epinephrine AS epi
  ON t.stay_id = epi.stay_id
  AND t.starttime >= epi.starttime
  AND t.endtime <= epi.endtime
LEFT JOIN mimiciv_derived.norepinephrine AS nor
  ON t.stay_id = nor.stay_id
  AND t.starttime >= nor.starttime
  AND t.endtime <= nor.endtime
LEFT JOIN mimiciv_derived.phenylephrine AS phe
  ON t.stay_id = phe.stay_id
  AND t.starttime >= phe.starttime
  AND t.endtime <= phe.endtime
LEFT JOIN mimiciv_derived.vasopressin AS vas
  ON t.stay_id = vas.stay_id
  AND t.starttime >= vas.starttime
  AND t.endtime <= vas.endtime
LEFT JOIN mimiciv_derived.milrinone AS mil
  ON t.stay_id = mil.stay_id
  AND t.starttime >= mil.starttime
  AND t.endtime <= mil.endtime
/* remove the final row for each stay_id */ /* it will not have any infusions associated with it */
WHERE
  NOT t.endtime IS NULL