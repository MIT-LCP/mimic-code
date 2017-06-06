-- ------------------------------------------------------------------
-- Original Source: https://github.com/MIT-LCP/mimic-code/blob/401132f256aff1e67161ce94cf0714ac1d344f5c/etc/firstday/vitals-first-day.sql
-- modified to calculate some data without the limitation of the first day 
-- and to get the data of each calendar day
-- ------------------------------------------------------------------

create table a_vitals as
SELECT pvt.subject_id, pvt.hadm_id, pvt.icustay_id

, min(case when VitalID = 2 then valuenum else null end) as SysBP_Min
, min(case when VitalID = 3 then valuenum else null end) as DiasBP_Min
, min(case when VitalID = 4 then valuenum else null end) as MeanBP_Min 
, dailyInterval

FROM  (
  select ie.subject_id, ie.hadm_id, ie.icustay_id
  , case
    when itemid in (51,442,455,6701,220179,220050) and valuenum > 0 and valuenum < 400 then 2 -- SysBP
    when itemid in (8368,8440,8441,8555,220180,220051) and valuenum > 0 and valuenum < 300 then 3 -- DiasBP
    when itemid in (456,52,6702,443,220052,220181,225312) and valuenum > 0 and valuenum < 300 then 4 -- MeanBP

    else null end as VitalID
      -- convert F to C
  , valuenum 
  , datediff('day', ie.intime::date, charttime::date) AS dailyInterval

  from icustays ie
  left join chartevents ce
  on ie.subject_id = ce.subject_id and ie.hadm_id = ce.hadm_id and ie.icustay_id = ce.icustay_id
  where ce.itemid in
  (

  -- Systolic/diastolic

  51, --	Arterial BP [Systolic]
  442, --	Manual BP [Systolic]
  455, --	NBP [Systolic]
  6701, --	Arterial BP #2 [Systolic]
  220179, --	Non Invasive Blood Pressure systolic
  220050, --	Arterial Blood Pressure systolic

  8368, --	Arterial BP [Diastolic]
  8440, --	Manual BP [Diastolic]
  8441, --	NBP [Diastolic]
  8555, --	Arterial BP #2 [Diastolic]
  220180, --	Non Invasive Blood Pressure diastolic
  220051, --	Arterial Blood Pressure diastolic

  -- MEAN ARTERIAL PRESSURE
  456, --"NBP Mean"
  52, --"Arterial BP Mean"
  6702, --	Arterial BP Mean #2
  443, --	Manual BP Mean(calc)
  220052, --"Arterial Blood Pressure mean"
  220181, --"Non Invasive Blood Pressure mean"
  225312  --"ART BP mean"

  )
) pvt
where dailyInterval < 10
group by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, dailyInterval
order by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, dailyInterval;
