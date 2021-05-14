select
  ie.icustay_id
  , min(case when itemid = 211 then valuenum else null end) as HeartRate_Min
  , max(case when itemid = 211 then valuenum else null end) as HeartRate_Max
  -- , min(case when itemid in (615,618) then valuenum else null end) as RespRate_Min
  -- , max(case when itemid in (615,618) then valuenum else null end) as RespRate_Max
from icustays ie
-- join to the chartevents table to get the observations
left join chartevents ce
  -- match the tables on the patient identifier
  on ie.icustay_id = ce.icustay_id
  and ce.charttime >= ie.intime and ce.charttime <= ie.intime + interval '1' day
  and ce.itemid = 211
group by ie.icustay_id
order by ie.icustay_id;
