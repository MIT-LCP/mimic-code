with mv as
(
  select
    pe.icustay_id
  , pe.starttime, pe.endtime
  , case
      when itemid in (225752, 224272)
        then 1
      when pe.locationcategory = 'Invasive Arterial'
        then 1
      when itemid = 225789 and pe.locationcategory IS NULL
        then 1
      else 0
    end as arterial_line
  FROM `physionet-data.mimiciii_clinical.procedureevents_mv` pe
  where pe.itemid in
  (
      224263 -- Multi Lumen | None | 12 | Processes
    -- , 224264 -- PICC Line | None | 12 | Processes
    , 224267 -- Cordis/Introducer | None | 12 | Processes
    , 224268 -- Trauma line | None | 12 | Processes
    , 225199 -- Triple Introducer | None | 12 | Processes
    -- , 225202 -- Indwelling Port (PortaCath) | None | 12 | Processes
    -- , 225203 -- Pheresis Catheter | None | 12 | Processes
    -- , 225315 -- Tunneled (Hickman) Line | None | 12 | Processes
    , 225752 -- Arterial Line | None | 12 | Processes
    , 225789 -- Sheath
    , 224272 -- IABP Line
    -- , 227719 -- AVA Line | None | 12 | Processes
    -- , 228286 -- Intraosseous Device | None | 12 | Processes
  )
)
, cv_grp as
(
  -- group type+site
  select ce.icustay_id, ce.charttime
    , max(case when itemid =  229  then value else null end) as INV1_Type
    , max(case when itemid =  8392 then value else null end) as INV1_Site
    , max(case when itemid =  235  then value else null end) as INV2_Type
    , max(case when itemid =  8393 then value else null end) as INV2_Site
    , max(case when itemid =  241  then value else null end) as INV3_Type
    , max(case when itemid =  8394 then value else null end) as INV3_Site
    , max(case when itemid =  247  then value else null end) as INV4_Type
    , max(case when itemid =  8395 then value else null end) as INV4_Site
    , max(case when itemid =  253  then value else null end) as INV5_Type
    , max(case when itemid =  8396 then value else null end) as INV5_Site
    , max(case when itemid =  259  then value else null end) as INV6_Type
    , max(case when itemid =  8397 then value else null end) as INV6_Site
    , max(case when itemid =  265  then value else null end) as INV7_Type
    , max(case when itemid =  8398 then value else null end) as INV7_Site
    , max(case when itemid =  271  then value else null end) as INV8_Type
    , max(case when itemid =  8399 then value else null end) as INV8_Site
  FROM `physionet-data.mimiciii_clinical.chartevents` ce
  where ce.itemid in
  (
      229 -- INV Line#1 [Type]
    , 235 -- INV Line#2 [Type]
    , 241 -- INV Line#3 [Type]
    , 247 -- INV Line#4 [Type]
    , 253 -- INV Line#5 [Type]
    , 259 -- INV Line#6 [Type]
    , 265 -- INV Line#7 [Type]
    , 271 -- INV Line#8 [Type]
    , 8392 -- INV Line#1 [Site]
    , 8393 -- INV Line#2 [Site]
    , 8394 -- INV Line#3 [Site]
    , 8395 -- INV Line#4 [Site]
    , 8396 -- INV Line#5 [Site]
    , 8397 -- INV Line#6 [Site]
    , 8398 -- INV Line#7 [Site]
    , 8399 -- INV Line#8 [Site]
  )
  and ce.value is not null
  group by ce.icustay_id, ce.charttime
)
-- types of invasive lines in carevue
--       value       | count
-- ------------------+--------
--  A-Line           | 460627
--  Multi-lumen      | 345858
--  PICC line        |  92285
--  PA line          |  65702
--  Dialysis Line    |  57579
--  Introducer       |  36027
--  CCO PA Line      |  24831
--                   |  22369
--  Trauma Line      |  15530
--  Portacath        |  12927
--  Ventriculostomy  |  10295
--  Pre-Sep Catheter |   9678
--  IABP             |   8819
--  Other/Remarks    |   8725
--  Midline          |   5067
--  Venous Access    |   4278
--  Hickman          |   3783
--  PacerIntroducer  |   2663
--  TripleIntroducer |   2262
--  RIC              |   1625
--  PermaCath        |   1066
--  Camino Bolt      |    913
--  Lumbar Drain     |    361
-- (23 rows)
, cv as
(
  select distinct icustay_id, charttime
  from cv_grp
  where (inv1_type in ('A-Line', 'IABP'))
     OR (inv2_type in ('A-Line', 'IABP'))
     OR (inv3_type in ('A-Line', 'IABP'))
     OR (inv4_type in ('A-Line', 'IABP'))
     OR (inv5_type in ('A-Line', 'IABP'))
     OR (inv6_type in ('A-Line', 'IABP'))
     OR (inv7_type in ('A-Line', 'IABP'))
     OR (inv8_type in ('A-Line', 'IABP'))
)
-- transform carevue data into durations
, cv0 as
(
  select
    icustay_id
    -- this carries over the previous charttime
    , LAG(CHARTTIME, 1) OVER (partition by icustay_id order by charttime) as charttime_lag
    , charttime
  from cv
)
, cv1 as
(
  select
    icustay_id
    , charttime
    , charttime_lag
    -- if the current observation indicates a line is present
    -- calculate the time since the last charted line
    , charttime - charttime_lag as arterial_line_duration
    -- now we determine if the current line is "new"
    -- new == no documentation for 16 hours
    , case
        when DATETIME_DIFF(charttime, charttime_lag, HOUR) > 16
          then 1
      else 0
      end as arterial_line_new
  FROM cv0
)
, cv2 as
(
  select cv1.*
  -- create a cumulative sum of the instances of new events
  -- this results in a monotonic integer assigned to each new instance of a line
  , SUM( arterial_line_new )
    OVER ( partition by icustay_id order by charttime )
    as arterial_line_rownum
  from cv1
)
-- create the durations for each line
, cv_dur as
(
  select icustay_id
    , arterial_line_rownum
    , min(charttime) as starttime
    , max(charttime) as endtime
    , DATETIME_DIFF(max(charttime), min(charttime), HOUR) AS duration_hours
  from cv2
  group by icustay_id, arterial_line_rownum
  having min(charttime) != max(charttime)
)
select icustay_id
  -- , arterial_line_rownum
  , starttime, endtime, duration_hours
from cv_dur
UNION ALL
--TODO: collapse metavision durations if they overlap
select icustay_id
  -- , ROW_NUMBER() over (PARTITION BY icustay_id ORDER BY starttime) as arterial_line_rownum
  , starttime, endtime
  , DATETIME_DIFF(endtime, starttime, HOUR) AS duration_hours
from mv
where arterial_line = 1
order by icustay_id, starttime;
