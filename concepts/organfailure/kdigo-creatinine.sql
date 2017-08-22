DROP MATERIALIZED VIEW IF EXISTS kdigo_creat CASCADE;
CREATE MATERIALIZED VIEW kdigo_creat as
with admcr as
(
select
    ie.icustay_id
  , le.VALUENUM as AdmCreat
  , le.CHARTTIME
  -- Create an index that goes from 1, 2, ..., N
  -- The index represents how early in the patient's stay a creatinine value was measured
  -- Consequently, when we later select index == 1, we only select the first (admission) creatinine
  -- In addition, we only select the first stay for the given subject_id
  , ROW_NUMBER ()
          OVER (PARTITION BY ie.icustay_id
                ORDER BY CHARTTIME
                    ) as rn
  from icustays ie
  left join labevents le
    on ie.subject_id = le.subject_id
    and le.ITEMID = 50912
    and le.VALUENUM is not null
    -- admission creatinine defined as [-6,24] from admission
    and le.CHARTTIME between (ie.INTIME - interval '6' hour) and (ie.INTIME + interval '1' day)
)
-- *****
-- Query to extract highest creatinine within 48 hours
-- *****
, highcr as
(
  select
    ie.subject_id, ie.hadm_id, ie.icustay_id
  , le.VALUENUM as HighCreat
  , le.CHARTTIME

  -- Create an index that goes from 1, 2, ..., N
  -- The index represents how high a creatinine value is
  -- Consequently, when we later select index == 1, we only select the highest creatinine
  , ROW_NUMBER ()
          OVER (PARTITION BY ie.icustay_id
                ORDER BY le.VALUENUM DESC
                    ) as rn
  from icustays ie
  left join labevents le
    on ie.subject_id = le.subject_id
    and le.ITEMID = 50912
    and le.VALUENUM is not null
    -- highest creatinine defined as [-6,48] from admission
    and le.CHARTTIME between (ie.INTIME - interval '6' hour) and (ie.INTIME + interval '2' day)
)
-- *****
-- Query to extract highest creatinine within 7 days
-- *****
, highcr7day as
(
  select
    ie.subject_id, ie.hadm_id, ie.icustay_id
  , le.VALUENUM as HighCreat
  , le.CHARTTIME

  -- Create an index that goes from 1, 2, ..., N
  -- The index represents how high a creatinine value is
  -- Consequently, when we later select index == 1, we only select the highest creatinine
  , ROW_NUMBER ()
          OVER (PARTITION BY ie.icustay_id
                ORDER BY le.VALUENUM DESC
                    ) as rn
  from icustays ie
  left join labevents le
    on ie.subject_id = le.subject_id
    and le.ITEMID = 50912
    and le.VALUENUM is not null
    -- highest creatinine between [-6,24*7] hours from admission
    and le.CHARTTIME between (ie.INTIME - interval '6' hour) and (ie.INTIME + interval '7' day)
)
-- *****
-- Final query
-- *****
select
b.subject_id, b.hadm_id, b.icustay_id, b.INTIME
, admcr.AdmCreat, admcr.CHARTTIME as AdmCreatTime
, highcr.HighCreat as HighCreat48hr, highcr.CHARTTIME as HighCreat48hrTime
, highcr7day.HighCreat as HighCreat7day, highcr7day.CHARTTIME as HighCreat7dayTime
--, db.DB, db.TIME as DBTIME
from icustays b
left join admcr
  on b.icustay_id = admcr.icustay_id
  and admcr.rn = 1
left join highcr7day
  on b.icustay_id = highcr7day.icustay_id
  and highcr7day.rn = 1
left join highcr
  on b.icustay_id = highcr.icustay_id
  and highcr.rn = 1;
