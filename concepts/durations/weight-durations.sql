-- This query extracts weights for adult ICU patients with start/stop times
-- if an admission weight is given, then this is assigned from intime to outtime

DROP MATERIALIZED VIEW IF EXISTS weightdurations CASCADE;
CREATE MATERIALIZED VIEW weightdurations as

-- This query extracts weights for adult ICU patients with start/stop times
-- if an admission weight is given, then this is assigned from intime to outtime
with wt_stg as
(
    SELECT
        c.icustay_id
      , c.charttime
      , case when c.itemid in (762,226512) then 'admit'
          else 'daily' end as weight_type
      -- TODO: eliminate obvious outliers if there is a reasonable weight
      , c.valuenum as weight
    FROM chartevents c
    WHERE c.valuenum IS NOT NULL
      AND c.itemid in
      (
         762,226512 -- Admit Wt
        ,763,224639 -- Daily Weight
      )
      AND c.valuenum != 0
      -- exclude rows marked as error
      AND c.error IS DISTINCT FROM 1
)
-- assign ascending row number
, wt_stg1 as
(
  select
      icustay_id
    , charttime
    , weight_type
    , weight
    , ROW_NUMBER() OVER (partition by icustay_id, weight_type order by charttime) as rn
  from wt_stg
)
-- change charttime to starttime - for admit weight, we use ICU admission time
, wt_stg2 as
(
  select
      wt_stg1.icustay_id
    , ie.intime, ie.outtime
    , case when wt_stg1.weight_type = 'admit' and wt_stg1.rn = 1
        then ie.intime - interval '2' hour
      else wt_stg1.charttime end as starttime
    , wt_stg1.weight
  from icustays ie
  inner join wt_stg1
    on ie.icustay_id = wt_stg1.icustay_id
  where not (weight_type = 'admit' and rn = 1)
)
, wt_stg3 as
(
  select
    icustay_id
    , starttime
    , coalesce(
        LEAD(starttime) OVER (PARTITION BY icustay_id ORDER BY starttime),
        outtime + interval '2' hour
      ) as endtime
    , weight
  from wt_stg2
)
-- this table is the start/stop times from admit/daily weight in charted data
, wt1 as
(
  select
      ie.icustay_id
    , wt.starttime
    , case when wt.icustay_id is null then null
      else
        coalesce(wt.endtime,
        LEAD(wt.starttime) OVER (partition by ie.icustay_id order by wt.starttime),
          -- we add a 2 hour "fuzziness" window
        ie.outtime + interval '2' hour)
      end as endtime
    , wt.weight
  from icustays ie
  left join wt_stg3 wt
    on ie.icustay_id = wt.icustay_id
)
-- if the intime for the patient is < the first charted daily weight
-- then we will have a "gap" at the start of their stay
-- to prevent this, we look for these gaps and backfill the first weight
-- this adds (153255-149657)=3598 rows, meaning this fix helps for up to 3598 icustay_id
, wt_fix as
(
  select ie.icustay_id
    -- we add a 2 hour "fuzziness" window
    , ie.intime - interval '2' hour as starttime
    , wt.starttime as endtime
    , wt.weight
  from icustays ie
  inner join
  -- the below subquery returns one row for each unique icustay_id
  -- the row contains: the first starttime and the corresponding weight
  (
    select wt1.icustay_id, wt1.starttime, wt1.weight
    from wt1
    inner join
      (
        select icustay_id, min(Starttime) as starttime
        from wt1
        group by icustay_id
      ) wt2
    on wt1.icustay_id = wt2.icustay_id
    and wt1.starttime = wt2.starttime
  ) wt
    on ie.icustay_id = wt.icustay_id
    and ie.intime < wt.starttime
)
, wt2 as
(
  select
      wt1.icustay_id
    , wt1.starttime
    , wt1.endtime
    , wt1.weight
  from wt1
  UNION
  SELECT
      wt_fix.icustay_id
    , wt_fix.starttime
    , wt_fix.endtime
    , wt_fix.weight
  from wt_fix
)
-- get more weights from echo - completes data for ~2500 patients
-- we only use echo data if there is *no* charted data
-- we impute the median echo weight for their entire ICU stay
-- only ~762 patients remain with no weight data
, echo_lag as
(
  select
    ie.icustay_id
    , ie.intime, ie.outtime
    , 0.453592*ec.weight as weight_echo
    , ROW_NUMBER() OVER (PARTITION BY ie.icustay_id ORDER BY ec.charttime) as rn
    , ec.charttime as starttime
    , LEAD(ec.charttime) OVER (PARTITION BY ie.icustay_id ORDER BY ec.charttime) as endtime
  from icustays ie
  inner join echodata ec
      on ie.hadm_id = ec.hadm_id
  where ec.weight is not null
)
, echo_final as
(
    select
        el.icustay_id
        , el.starttime
          -- we add a 2 hour "fuzziness" window
        , coalesce(el.endtime,el.outtime + interval '2' hour) as endtime
        , weight_echo
    from echo_lag el
    UNION
    -- if the starttime was later than ICU admission, back-propogate the weight
    select
      el.icustay_id
      , el.intime - interval '2' hour as starttime
      , el.starttime as endtime
      , el.weight_echo
    from echo_lag el
    where el.rn = 1
    and el.starttime > el.intime - interval '2' hour
)
select
  wt2.icustay_id, wt2.starttime, wt2.endtime, wt2.weight
from wt2
UNION
-- only add echos if we have no charted weight data
select
  ef.icustay_id, ef.starttime, ef.endtime, ef.weight_echo as weight
from echo_final ef
where ef.icustay_id not in (select distinct icustay_id from wt2)
order by icustay_id, starttime, endtime;
