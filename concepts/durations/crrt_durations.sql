with crrt_settings as
(
  select ce.icustay_id, ce.charttime
  , max(
      case
        when ce.itemid in
        (
          224149, -- Access Pressure
          224144, -- Blood Flow (ml/min)
          228004, -- Citrate (ACD-A)
          225183, -- Current Goal
          225977, -- Dialysate Fluid
          224154, -- Dialysate Rate
          224151, -- Effluent Pressure
          224150, -- Filter Pressure
          225958, -- Heparin Concentration (units/mL)
          224145, -- Heparin Dose (per hour)
          224191, -- Hourly Patient Fluid Removal
          228005, -- PBP (Prefilter) Replacement Rate
          228006, -- Post Filter Replacement Rate
          225976, -- Replacement Fluid
          224153, -- Replacement Rate
          224152, -- Return Pressure
          226457  -- Ultrafiltrate Output
        ) then 1
      when ce.itemid in
        (
        29,  -- Access mmHg
        173, -- Effluent Press mmHg
        192, -- Filter Pressure mmHg
        624, -- Return Pressure mmHg
        79, -- Blood Flow ml/min
        142, -- Current Goal
        146, -- Dialysate Flow ml/hr
        611, -- Replace Rate ml/hr
        5683 -- Hourly PFR
        ) then 1
      when ce.itemid = 665 and value in ('Active','Clot Increasing','Clots Present','No Clot Present')
         then 1
      when ce.itemid = 147 and value = 'Yes'
         then 1
      else 0 end)
      as RRT
  -- Below indicates that a new instance of CRRT has started
  , max(
    case
      -- System Integrity
      when ce.itemid = 224146 and value in ('New Filter','Reinitiated')
        then 1
      when ce.itemid = 665 and value in ('Initiated')
        then 1
    else 0
   end ) as RRT_start
  -- Below indicates that the current instance of CRRT has ended
  , max(
    case
      -- System Integrity
      when ce.itemid = 224146 and value in ('Discontinued','Recirculating')
        then 1
      -- the only value like DC is "DC'D", use like to avoid apostrophe
      when ce.itemid = 665 and (value = 'Clotted' OR value LIKE 'DC%')
        then 1
      -- Reason for CRRT filter change
      when ce.itemid = 225956
        then 1
    else 0
   end ) as RRT_end
  FROM `physionet-data.mimiciii_clinical.chartevents` ce
  where ce.itemid in
  (
    -- MetaVision ITEMIDs
    -- Below require special handling
    224146, -- System Integrity
    225956,  -- Reason for CRRT Filter Change
    -- Below are settings which indicate CRRT is started/continuing
    224149, -- Access Pressure
    224144, -- Blood Flow (ml/min)
    228004, -- Citrate (ACD-A)
    225183, -- Current Goal
    225977, -- Dialysate Fluid
    224154, -- Dialysate Rate
    224151, -- Effluent Pressure
    224150, -- Filter Pressure
    225958, -- Heparin Concentration (units/mL)
    224145, -- Heparin Dose (per hour)
    224191, -- Hourly Patient Fluid Removal
    228005, -- PBP (Prefilter) Replacement Rate
    228006, -- Post Filter Replacement Rate
    225976, -- Replacement Fluid
    224153, -- Replacement Rate
    224152, -- Return Pressure
    226457, -- Ultrafiltrate Output
    -- CareVue ITEMIDs
    -- Below require special handling
    665,  -- System integrity
    147, -- Dialysate Infusing
    612, -- Replace.Fluid Infuse
    -- Below are settings which indicate CRRT is started/continuing
    29,  -- Access mmHg
    173, -- Effluent Press mmHg
    192, -- Filter Pressure mmHg
    624, -- Return Pressure mmHg
    142, -- Current Goal
    79, -- Blood Flow ml/min
    146, -- Dialysate Flow ml/hr
    611, -- Replace Rate ml/hr
    5683 -- Hourly PFR
  )
  and ce.value is not null
  and coalesce(ce.valuenum,1) != 0 -- non-zero rates/values
  group by icustay_id, charttime
)
-- create various lagged variables for future query
, vd_lag AS
(
  select
    icustay_id
    -- this carries over the previous charttime
    , LAG(CHARTTIME, 1) OVER W AS charttime_prev_row
    , charttime
    , RRT
    , RRT_start
    , RRT_end
    , LAG(RRT_end, 1) OVER W AS rrt_ended_prev_row
  FROM crrt_settings
  WINDOW w AS 
  (
    partition by icustay_id, case when RRT=1 or RRT_end=1 then 1 else 0 end
    order by charttime
  )
)
, vd1 as
(
  select
      icustay_id
      , charttime
      , RRT
      , RRT_start
      , RRT_end

      -- now we determine if the current event is a new instantiation
      , case
          when RRT_start = 1
            then 1
        -- if there is an end flag, we mark any subsequent event as new
          when RRT_end = 1
            -- note the end is *not* a new event, the *subsequent* row is
            -- so here we output 0
            then 0
          when rrt_ended_prev_row = 1
            then 1
            -- if there is less than 2 hours between CRRT settings, we do not treat this as a new CRRT event
          when DATETIME_DIFF(charttime, charttime_prev_row, HOUR) <= 2
            then 0
        else 1
      end as NewCRRT
  -- use the temp table with only settings FROM `physionet-data.mimiciii_clinical.chartevents`
  FROM vd_lag
)
, vd2 as
(
  select vd1.*
  -- create a cumulative sum of the instances of new CRRT
  -- this results in a monotonically increasing integer assigned to each CRRT
  , case when RRT_start = 1 or RRT=1 or RRT_end = 1 then
      SUM( NewCRRT )
      OVER ( partition by icustay_id order by charttime )
    else null end
    as num
  --- now we convert CHARTTIME of CRRT settings into durations
  from vd1
  -- now we can isolate to just rows with settings
  -- (before we had rows with start/end flags)
  -- this removes any null values for NewCRRT
  where
    RRT_start = 1 or RRT = 1 or RRT_end = 1
)
-- create the durations for each CRRT instance
, fin as
(
select icustay_id
  , num
  , min(charttime) as starttime
  , max(charttime) as endtime
 	, DATETIME_DIFF(max(charttime), min(charttime), HOUR) AS duration_hours
  -- add durations
from vd2
group by icustay_id, num
having min(charttime) != max(charttime)
)
select icustay_id
  , ROW_NUMBER() over (partition by icustay_id order by starttime) as num
  , starttime, endtime, duration_hours
from fin
order by icustay_id, num
