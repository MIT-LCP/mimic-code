-- This query checks if the patient had AKI according to KDIGO.
-- AKI is calculated every time a creatinine or urine output measurement occurs.
-- Baseline creatinine is defined as the lowest creatinine in the past 7 days.

DROP MATERIALIZED VIEW IF EXISTS kdigo_stages;
CREATE MATERIALIZED VIEW kdigo_stages AS
-- get creatinine stages
with cr_stg AS
(
  SELECT
    cr.icustay_id
    , cr.charttime
    , cr.creat
    , case
        -- 3x baseline
        when cr.creat >= (cr.creat_low_past_7day*3.0) then 3
        -- *OR* cr >= 4.0 with associated increase
        when cr.creat >= 4
        -- For patients reaching Stage 3 by SCr >4.0 mg/dl
        -- require that the patient first achieve ... acute increase >= 0.3 within 48 hr
        -- *or* an increase of >= 1.5 times baseline
        and (cr.creat_low_past_48hr <= 3.7 OR cr.creat >= (1.5*cr.creat_low_past_7day))
            then 3 
        -- TODO: initiation of RRT
        when cr.creat >= (cr.creat_low_past_7day*2.0) then 2
        when cr.creat >= (cr.creat_low_past_48hr+0.3) then 1
        when cr.creat >= (cr.creat_low_past_7day*1.5) then 1
    else 0 end as aki_stage_creat
  FROM kdigo_creat cr
)
-- stages for UO / creat
, uo_stg as
(
  select
      uo.icustay_id
    , uo.charttime
    , uo.weight
    , uo.uo_rt_6hr
    , uo.uo_rt_12hr
    , uo.uo_rt_24hr
    -- AKI stages according to urine output
    , case
        when uo.uo_rt_6hr is null then null
        when uo.uo_rt_24hr < 0.3 then 3
        when uo.uo_rt_12hr = 0 then 3
        when uo.uo_rt_12hr < 0.5 then 2
        when uo.uo_rt_6hr  < 0.5 then 1
    else 0 end as aki_stage_uo
  from kdigo_uo uo
)
-- get all charttimes documented
, tm_stg AS
(
    SELECT
      icustay_id, charttime
    FROM cr_stg
    UNION
    SELECT
      icustay_id, charttime
    FROM uo_stg
)
select
    ie.icustay_id
  , tm.charttime
  , cr.creat
  , cr.aki_stage_creat
  , uo.uo_rt_6hr
  , uo.uo_rt_12hr
  , uo.uo_rt_24hr
  , uo.aki_stage_uo
  -- Classify AKI using both creatinine/urine output criteria
  , GREATEST(cr.aki_stage_creat, uo.aki_stage_uo) AS aki_stage
FROM icustays ie
-- get all possible charttimes as listed in tm_stg
LEFT JOIN tm_stg tm
  ON ie.icustay_id = tm.icustay_id
LEFT JOIN cr_stg cr
  ON ie.icustay_id = cr.icustay_id
  AND tm.charttime = cr.charttime
LEFT JOIN uo_stg uo
  ON ie.icustay_id = uo.icustay_id
  AND tm.charttime = uo.charttime
order by ie.icustay_id, tm.charttime;
