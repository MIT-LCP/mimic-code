-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS weight_durations; CREATE TABLE weight_durations AS 
-- This query extracts weights for adult ICU patients with start/stop times
-- if an admission weight is given, then this is assigned from intime to outtime
WITH wt_stg as
(
    SELECT
        c.stay_id
      , c.charttime
      , case when c.itemid = 226512 then 'admit'
          else 'daily' end as weight_type
      -- TODO: eliminate obvious outliers if there is a reasonable weight
      , c.valuenum as weight
    FROM mimiciv_icu.chartevents c
    WHERE c.valuenum IS NOT NULL
      AND c.itemid in
      (
          226512 -- Admit Wt
          , 224639 -- Daily Weight
      )
      AND c.valuenum > 0
)
-- assign ascending row number
, wt_stg1 as
(
  select
      stay_id
    , charttime
    , weight_type
    , weight
    , ROW_NUMBER() OVER (partition by stay_id, weight_type order by charttime) as rn
  from wt_stg
  WHERE weight IS NOT NULL
)
-- change charttime to intime for the first admission weight recorded
, wt_stg2 AS
(
  SELECT 
      wt_stg1.stay_id
    , ie.intime, ie.outtime
    , wt_stg1.weight_type
    , case when wt_stg1.weight_type = 'admit' and wt_stg1.rn = 1
        then DATETIME_SUB(ie.intime, INTERVAL '2' HOUR)
      else wt_stg1.charttime end as starttime
    , wt_stg1.weight
  from wt_stg1
  INNER JOIN mimiciv_icu.icustays ie
    on ie.stay_id = wt_stg1.stay_id
)
, wt_stg3 as
(
  select
    stay_id
    , intime, outtime
    , starttime
    , coalesce(
        LEAD(starttime) OVER (PARTITION BY stay_id ORDER BY starttime),
        DATETIME_ADD(outtime, INTERVAL '2' HOUR)
      ) as endtime
    , weight
    , weight_type
  from wt_stg2
)
-- this table is the start/stop times from admit/daily weight in charted data
, wt1 as
(
  select
      stay_id
    , starttime
    , coalesce(endtime,
      LEAD(starttime) OVER (partition by stay_id order by starttime),
      -- impute ICU discharge as the end of the final weight measurement
      -- plus a 2 hour "fuzziness" window
      DATETIME_ADD(outtime, INTERVAL '2' HOUR)
    ) as endtime
    , weight
    , weight_type
  from wt_stg3
)
-- if the intime for the patient is < the first charted daily weight
-- then we will have a "gap" at the start of their stay
-- to prevent this, we look for these gaps and backfill the first weight
-- this adds (153255-149657)=3598 rows, meaning this fix helps for up to 3598 stay_id
, wt_fix as
(
  select ie.stay_id
    -- we add a 2 hour "fuzziness" window
    , DATETIME_SUB(ie.intime, INTERVAL '2' HOUR) as starttime
    , wt.starttime as endtime
    , wt.weight
    , wt.weight_type
  from mimiciv_icu.icustays ie
  inner join
  -- the below subquery returns one row for each unique stay_id
  -- the row contains: the first starttime and the corresponding weight
  (
    SELECT wt1.stay_id, wt1.starttime, wt1.weight
    , weight_type
    , ROW_NUMBER() OVER (PARTITION BY wt1.stay_id ORDER BY wt1.starttime) as rn
    FROM wt1
  ) wt
    ON  ie.stay_id = wt.stay_id
    AND wt.rn = 1
    and ie.intime < wt.starttime
)
-- add the backfill rows to the main weight table
SELECT
wt1.stay_id
, wt1.starttime
, wt1.endtime
, wt1.weight
, wt1.weight_type
FROM wt1
UNION ALL
SELECT
wt_fix.stay_id
, wt_fix.starttime
, wt_fix.endtime
, wt_fix.weight
, wt_fix.weight_type
FROM wt_fix;