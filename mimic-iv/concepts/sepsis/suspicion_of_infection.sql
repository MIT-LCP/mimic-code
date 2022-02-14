WITH ab_tbl AS 
(
  select
      abx.subject_id, abx.hadm_id, abx.stay_id
    , abx.antibiotic
    , abx.starttime AS antibiotic_time
    -- date is used to match microbiology cultures with only date available
    , DATETIME_TRUNC(abx.starttime, DAY) AS antibiotic_date
    , abx.stoptime AS antibiotic_stoptime
    -- create a unique identifier for each patient antibiotic
    , ROW_NUMBER() OVER
    (
      PARTITION BY subject_id
      ORDER BY starttime, stoptime, antibiotic
    ) AS ab_id
  from `physionet-data.mimic_derived.antibiotic` abx
)
-- culture followed by an antibiotic
, me_and_ab AS
(
  select
    ab_tbl.subject_id
    , ab_tbl.hadm_id
    , ab_tbl.stay_id
    , ab_tbl.ab_id
    , ab_tbl.antibiotic
    , ab_tbl.antibiotic_time
    , ab_tbl.antibiotic_date
    
    -- the associated microbiology culture
    , me.micro_specimen_id
    , me.charttime AS micro_charttime
    , DATETIME(me.chartdate) AS micro_chartdate
    , me.positive_culture
    , me.specimen
    , me.test_name

    -- we will use this partition to select the earliest culture before this abx
    -- this ensures each antibiotic is only matched to a single culture
    -- and consequently we have 1 row per antibiotic
    , ROW_NUMBER() OVER
    (
      PARTITION BY ab_tbl.subject_id, ab_tbl.ab_id
      ORDER BY me.chartdate, me.charttime NULLS LAST
    ) AS micro_seq
  from ab_tbl
  -- we join to microbiology with two clauses
  -- (1) for data with charttime
  -- (2) for data with only chartdate
  -- ... because we want to include dates which may be excluded by fencepost errors
  -- e.g. abx at 2100-04-16 08:00, and micro at 2100-04-13 00:00
  LEFT JOIN `physionet-data.mimic_derived.culture` me
    on ab_tbl.subject_id = me.subject_id
    and
    (
      (
      -- if charttime is available, use it
          me.charttime is not null
      and ab_tbl.antibiotic_time >= DATETIME_SUB(me.charttime, INTERVAL 24 HOUR)
      and ab_tbl.antibiotic_time <= DATETIME_ADD(me.charttime, INTERVAL 3 DAY) 
      )
      OR
      (
      -- if charttime is not available, use chartdate
          me.charttime is null
      and antibiotic_date >= DATE_SUB(me.chartdate, INTERVAL 1 DAY)
      and antibiotic_date <= DATE_ADD(me.chartdate, INTERVAL 3 DAY)
      )
    )
)
SELECT
subject_id
, hadm_id
, stay_id
, ab_id
-- time of suspected infection:
--    (1) the culture time (if before antibiotic)
--    (2) or the antibiotic time (if before culture)
, CASE
  WHEN micro_charttime < antibiotic_time THEN micro_charttime
  WHEN micro_charttime >= antibiotic_time THEN antibiotic_time
  WHEN micro_chartdate < antibiotic_date THEN micro_chartdate
  WHEN micro_chartdate >= antibiotic_date THEN antibiotic_date
  END AS suspected_infection_time

, antibiotic
, antibiotic_time

-- the specimen that was cultured
, specimen
, test_name
, COALESCE(micro_charttime, micro_chartdate) AS culture_time

-- whether the cultured specimen ended up being positive or not
, positive_culture

FROM me_and_ab
-- filter to the earliest micro for this abx
-- all rows
WHERE micro_seq = 1
;