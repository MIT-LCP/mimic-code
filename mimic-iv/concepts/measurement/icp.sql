with ce as
(
  select
  ce.subject_id
  , ce.stay_id
  , ce.charttime
  -- TODO: handle high ICPs when monitoring two ICPs
  , case when valuenum > 0 and valuenum < 100 then valuenum else null end as icp
  FROM `physionet-data.mimiciv_icu.chartevents` ce
  -- exclude rows marked as error
  where ce.itemid in
  (
    220765 -- Intra Cranial Pressure -- 92306
  , 227989 -- Intra Cranial Pressure #2 -- 1052
  )
)
select
  ce.subject_id
  , ce.stay_id
  , ce.charttime
  , MAX(icp) as icp
from ce
group by ce.subject_id, ce.stay_id, ce.charttime
;