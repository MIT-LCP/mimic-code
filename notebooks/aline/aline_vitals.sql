
DROP MATERIALIZED VIEW IF EXISTS ALINE_VITALS CASCADE;
CREATE MATERIALIZED VIEW ALINE_VITALS as

-- first, group together ITEMIDs for the same vital sign
with vitals_stg0 as
(
  select
    co.icustay_id, charttime
    , case
        -- MAP, Temperature, HR, CVP, SpO2,
        when itemid in (456,52,6702,443,220052,220181,225312) then 'MAP'
        when itemid in (223762,676,223761,678) then 'Temperature'
        when itemid in (211,220045) then 'HeartRate'
        when itemid in (646,220277) then 'SpO2'
      else null end as label

    , case when itemid in (223761,678) and ((valuenum-32)/1.8)<10 then null
           when itemid in (223762,676) and valuenum < 10 then null
           -- convert F to C
           when itemid in (223761,678) then (valuenum-32)/1.8
           -- sanity checks on data - one outliter with spo2 < 25
           when itemid in (646,220277) and valuenum <= 25 then null
        else valuenum end as valuenum
    , case when ce.charttime > co.vent_starttime then 1 else 0 end as obs_after_vent
  from ALINE_COHORT co
  inner join chartevents ce
    on ce.icustay_id = co.icustay_id
    and ce.charttime <= co.vent_starttime + interval '4' hour
    and ce.charttime >= co.vent_starttime - interval '1' day
    and itemid in
    (
        456,52,6702,443,220052,220181,225312 -- map
      , 223762,676,223761,678 -- temp
      , 211,220045 -- hr
      , 646,220277 -- spo2
    )
    and valuenum is not null
    and coalesce(error,0) != 1
)
-- next, assign an integer where rn=1 is the vital sign just preceeding vent
, vitals_stg1 as
(
  select
    icustay_id, label, valuenum, obs_after_vent
    , ROW_NUMBER() over (partition by icustay_id, label, obs_after_vent order by charttime DESC) as rn
  from vitals_stg0
)
-- now aggregate where rn=1 to give the vital sign just before the vent starttime
, vitals as
(
  select
    icustay_id
    -- this code prioritizes observations made before ventilation
    -- but if they are admitted ventilated then we allow some fuzziness
    , coalesce(min(case when rn = 1 and obs_after_vent = 0 and label = 'MAP' then valuenum else null end),
    min(case when rn = 1 and obs_after_vent = 1 and label = 'MAP' then valuenum else null end)) as MAP
    , coalesce(min(case when rn = 1 and obs_after_vent = 0 and label = 'Temperature' then valuenum else null end),
    min(case when rn = 1 and obs_after_vent = 1 and label = 'Temperature' then valuenum else null end)) as Temperature
    , coalesce(min(case when rn = 1 and obs_after_vent = 0 and label = 'HeartRate' then valuenum else null end),
    min(case when rn = 1 and obs_after_vent = 1 and label = 'HeartRate' then valuenum else null end)) as HeartRate
    , coalesce(min(case when rn = 1 and obs_after_vent = 0 and label = 'SpO2' then valuenum else null end),
    min(case when rn = 1 and obs_after_vent = 1 and label = 'SpO2' then valuenum else null end)) as SpO2
  from vitals_stg1
  group by icustay_id
)
select
  co.icustay_id, v.MAP, v.Temperature, v.HeartRate, v.SpO2
from aline_cohort co
left join vitals v
  on co.icustay_id = v.icustay_id;
