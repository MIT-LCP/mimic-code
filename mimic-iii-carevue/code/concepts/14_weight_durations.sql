drop table if exists weight_durations; create table weight_durations as 

with wt_neonate as
( 
    select c.icustay_id, c.charttime
    , max(case when c.itemid = 3580 then c.valuenum end) as wt_kg
    , max(case when c.itemid = 3581 then c.valuenum end) as wt_lb
    , max(case when c.itemid = 3582 then c.valuenum end) as wt_oz
    from chartevents c
    where c.itemid in (3580, 3581, 3582)
    and c.icustay_id is not null
    and coalesce(c.error, 0) = 0
    -- wt_oz/wt_lb/wt_kg are only 0 erroneously, so drop these rows
    and c.valuenum > 0
  -- a separate query was run to manually verify only 1 value exists per
  -- icustay_id/charttime/itemid grouping
  -- therefore, we can use max() across itemid to collapse these values to 1 row per group
    group by c.icustay_id, c.charttime
)

, birth_wt as
(
    select c.icustay_id, c.charttime
    , max(
      case
      when c.itemid = 4183 then
        -- clean free-text birth weight data
        case
          -- ignore value if there are any non-numeric characters
          when c.value ~ '[^0-9\\.]' then null 
          -- convert grams to kd
          when cast(c.value as numeric) > 100 then cast(c.value as numeric)/1000
          -- keep kg as is, filtering bad values (largest baby ever born was conveniently 9.98kg)
          when cast(c.value as numeric) < 10 then cast(c.value as numeric)
          -- ignore other values (those between 10-100) - junk data
        else null end
      -- itemid 3723 happily has all numeric data - also doesn't store any grams data
      when c.itemid = 3723 and c.valuenum < 10 then c.valuenum
      else null end) as wt_kg
    from chartevents c
    where c.itemid in (3723, 4183)
    and c.icustay_id is not null
    and coalesce(c.error, 0) = 0
  -- a separate query was run to manually verify only 1 value exists per
  -- icustay_id/charttime/itemid grouping
  -- therefore, we can use max() across itemid to collapse these values to 1 row per group
    group by c.icustay_id, c.charttime
)

, wt_stg as
(
    select
        c.icustay_id
      , c.charttime
      , case when c.itemid in (762,226512) then 'admit'
          else 'daily' end as weight_type
      -- TODO: eliminate obvious outliers if there is a reasonable weight
      , c.valuenum as weight
    from chartevents c
    where c.valuenum is not null
      and c.itemid in
      (
          762,226512 -- Admit Wt
        , 763,224639 -- Daily Weight
      )
      and c.icustay_id is not null
      and c.valuenum > 0
      -- exclude rows marked as error
      and coalesce(c.error, 0) = 0
    union all
    select
        n.icustay_id
      , n.charttime
      , 'daily' as weight_type
      , case
          when wt_kg is not null then wt_kg
          when wt_lb is not null then wt_lb*0.45359237 + wt_oz*0.0283495231
        else null end as weight
    from wt_neonate n
    union all
    select
        b.icustay_id
      , b.charttime
      -- birth weight of neonates is treated as admission weight
      , 'admit' as weight_type
      , wt_kg as weight
    from birth_wt b
)

, wt_stg0 as
(
  select icustay_id, charttime, weight_type, weight
  from wt_stg
)

-- assign ascending row number
, wt_stg1 as
(
  select
      icustay_id
    , charttime
    , weight_type
    , weight
    , row_number() over (partition by icustay_id, weight_type order by charttime) as rn
  from wt_stg0
  where weight is not null
)

-- change charttime to intime for the first admission weight recorded
, wt_stg2 as
(
  select 
      wt_stg1.icustay_id
    , ie.intime, ie.outtime
    , case when wt_stg1.weight_type = 'admit' and wt_stg1.rn = 1
        then ie.intime - interval '2 hour'
      else wt_stg1.charttime end as starttime
    , wt_stg1.weight
  from wt_stg1
  inner join icustays ie
    on ie.icustay_id = wt_stg1.icustay_id
)
, wt_stg3 as
(
  select
    icustay_id
    , intime, outtime
    , starttime
    , coalesce(
        lead(starttime) over (partition by icustay_id order by starttime),
        greatest(outtime, starttime) + interval '2 hour'
      ) as endtime
    , weight
  from wt_stg2
)
-- this table is the start/stop times from admit/daily weight in charted data
, wt1 as
(
  select
      icustay_id
    , starttime
    , coalesce(endtime,
      lead(starttime) over (partition by icustay_id order by starttime),
      -- impute ICU discharge as the end of the final weight measurement
      -- plus a 2 hour "fuzziness" window
      outtime + interval '2 hour'
    ) as endtime
    , weight
  from wt_stg3
)
-- if the intime for the patient is < the first charted daily weight
-- then we will have a "gap" at the start of their stay
-- to prevent this, we look for these gaps and backfill the first weight
, wt_fix as
(
  select ie.icustay_id
    -- we add a 2 hour "fuzziness" window
    , ie.intime - interval '2 hour' as starttime
    , wt.starttime as endtime
    , wt.weight
  from icustays ie
  inner join
  -- the below subquery returns one row for each unique icustay_id
  -- the row contains: the first starttime and the corresponding weight
  (
    select wt1.icustay_id, wt1.starttime, wt1.weight
    , row_number() over (partition by wt1.icustay_id order by wt1.starttime) as rn
    from wt1
  ) wt
    on  ie.icustay_id = wt.icustay_id
    and wt.rn = 1
    and ie.intime < wt.starttime
)
-- add the backfill rows to the main weight table
select
    wt1.icustay_id
  , wt1.starttime
  , wt1.endtime
  , wt1.weight
from wt1
union all
select
    wt_fix.icustay_id
  , wt_fix.starttime
  , wt_fix.endtime
  , wt_fix.weight
from wt_fix;