with ce as
(
  select ce.icustay_id
    , ce.charttime
    -- TODO: handle high ICPs when monitoring two ICPs
    , case when valuenum > 0 and valuenum < 100 then valuenum else null end as icp
  FROM `physionet-data.mimiciii_clinical.chartevents` ce
  -- exclude rows marked as error
  where (ce.error IS NULL OR ce.error = 0)
  and ce.icustay_id IS NOT NULL
  and ce.itemid in
  (
   226 -- ICP -- 99159
  ,1374 -- ICP Right -- 100
  ,2045 -- icp left -- 70
  ,2635 -- VENT ICP -- 195
  ,2660 -- ICP Camino -- 40
  ,2733 -- RIGHT VENT ICP -- 203
  ,2745 -- ICP LEFT -- 232
  ,2870 -- ICP-ventriculostomuy -- 114
  ,2956 -- ventriculostomy icp -- 64
  ,2985 -- ICP ventricle -- 85
  ,5856 -- icp -- 7
  ,7116 -- Rt ICP -- 80
  ,8218 -- left icp -- 6
  ,8298 -- L ICP -- 47
  ,8299 -- R ICP -- 16
  ,8305 -- ICP  Right -- 49
  ,220765 -- Intra Cranial Pressure -- 92306
  ,227989 -- Intra Cranial Pressure #2 -- 1052
  )
)
select
    ce.icustay_id
  , ce.charttime
  , MAX(icp) as icp
from ce
group by ce.icustay_id, ce.charttime
order by ce.icustay_id, ce.charttime;