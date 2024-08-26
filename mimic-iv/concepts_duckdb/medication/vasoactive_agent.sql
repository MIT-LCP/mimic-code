-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.vasoactive_agent; CREATE TABLE mimiciv_derived.vasoactive_agent AS
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
    vasotime AS starttime,
    LEAD(vasotime, 1) OVER (PARTITION BY stay_id ORDER BY vasotime NULLS FIRST) AS endtime
  FROM tm
)
SELECT
  t.stay_id,
  t.starttime,
  t.endtime,
  dop.vaso_rate AS dopamine,
  epi.vaso_rate AS epinephrine,
  nor.vaso_rate AS norepinephrine,
  phe.vaso_rate AS phenylephrine,
  vas.vaso_rate AS vasopressin,
  dob.vaso_rate AS dobutamine,
  mil.vaso_rate AS milrinone
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
WHERE
  NOT t.endtime IS NULL