-- create a table which has fuzzy boundaries on hospital admission
-- involves first creating a lag/lead version of disch/admit time
-- get first/last heart rate measurement during hospitalization for each stay_id
WITH t1 AS
(
    select ce.stay_id
    , min(charttime) as intime_hr
    , max(charttime) as outtime_hr
    FROM `physionet-data.mimiciv_icu.chartevents` ce
    -- only look at heart rate
    where ce.itemid = 220045
    group by ce.stay_id
)
-- add in subject_id/hadm_id
select
  ie.subject_id, ie.hadm_id, ie.stay_id
  , t1.intime_hr
  , t1.outtime_hr
FROM `physionet-data.mimiciv_icu.icustays` ie
left join t1
  on ie.stay_id = t1.stay_id;