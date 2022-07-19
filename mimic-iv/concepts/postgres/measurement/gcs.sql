-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS gcs; CREATE TABLE gcs AS 
-- This query extracts the Glasgow Coma Scale, a measure of neurological function.
-- The query has a few special rules:
--    (1) The verbal component can be set to 0 if the patient is ventilated.
--    This is corrected to 5 - the overall GCS is set to 15 in these cases.
--    (2) Often only one of three components is documented. The other components
--    are carried forward.

-- ITEMIDs used:

-- METAVISION
--    223900 GCS - Verbal Response
--    223901 GCS - Motor Response
--    220739 GCS - Eye Opening

-- Note:
--  The GCS for sedated patients is defaulted to 15 in this code.
--  This is in line with how the data is meant to be collected.
--  e.g., from the SAPS II publication:
--    For sedated patients, the Glasgow Coma Score before sedation was used.
--    This was ascertained either from interviewing the physician who ordered the sedation,
--    or by reviewing the patient's medical record.
with base as
(
  select
    subject_id
  , ce.stay_id, ce.charttime
  -- pivot each value into its own column
  , max(case when ce.ITEMID = 223901 then ce.valuenum else null end) as GCSMotor
  , max(case
      when ce.ITEMID = 223900 and ce.VALUE = 'No Response-ETT' then 0
      when ce.ITEMID = 223900 then ce.valuenum
      else null
    end) as GCSVerbal
  , max(case when ce.ITEMID = 220739 then ce.valuenum else null end) as GCSEyes
  -- convert the data into a number, reserving a value of 0 for ET/Trach
  , max(case
      -- endotrach/vent is assigned a value of 0
      -- flag it here to later parse specially
      when ce.ITEMID = 223900 and ce.VALUE = 'No Response-ETT' then 1 -- metavision
    else 0 end)
    as endotrachflag
  , ROW_NUMBER ()
          OVER (PARTITION BY ce.stay_id ORDER BY ce.charttime ASC) as rn
  from mimiciv_icu.chartevents ce
  -- Isolate the desired GCS variables
  where ce.ITEMID in
  (
    -- GCS components, Metavision
    223900, 223901, 220739
  )
  group by ce.subject_id, ce.stay_id, ce.charttime
)
, gcs as (
  select b.*
  , b2.GCSVerbal as GCSVerbalPrev
  , b2.GCSMotor as GCSMotorPrev
  , b2.GCSEyes as GCSEyesPrev
  -- Calculate GCS, factoring in special case when they are intubated and prev vals
  -- note that the coalesce are used to implement the following if:
  --  if current value exists, use it
  --  if previous value exists, use it
  --  otherwise, default to normal
  , case
      -- replace GCS during sedation with 15
      when b.GCSVerbal = 0
        then 15
      when b.GCSVerbal is null and b2.GCSVerbal = 0
        then 15
      -- if previously they were intub, but they aren't now, do not use previous GCS values
      when b2.GCSVerbal = 0
        then
            coalesce(b.GCSMotor,6)
          + coalesce(b.GCSVerbal,5)
          + coalesce(b.GCSEyes,4)
      -- otherwise, add up score normally, imputing previous value if none available at current time
      else
            coalesce(b.GCSMotor,coalesce(b2.GCSMotor,6))
          + coalesce(b.GCSVerbal,coalesce(b2.GCSVerbal,5))
          + coalesce(b.GCSEyes,coalesce(b2.GCSEyes,4))
      end as GCS

  from base b
  -- join to itself within 6 hours to get previous value
  left join base b2
    on b.stay_id = b2.stay_id
    and b.rn = b2.rn+1
    and b2.charttime > DATETIME_SUB(b.charttime, INTERVAL '6' HOUR)
)
-- combine components with previous within 6 hours
-- filter down to cohort which is not excluded
-- truncate charttime to the hour
, gcs_stg as
(
  select
    subject_id
  , gs.stay_id, gs.charttime
  , GCS
  , coalesce(GCSMotor,GCSMotorPrev) as GCSMotor
  , coalesce(GCSVerbal,GCSVerbalPrev) as GCSVerbal
  , coalesce(GCSEyes,GCSEyesPrev) as GCSEyes
  , case when coalesce(GCSMotor,GCSMotorPrev) is null then 0 else 1 end
  + case when coalesce(GCSVerbal,GCSVerbalPrev) is null then 0 else 1 end
  + case when coalesce(GCSEyes,GCSEyesPrev) is null then 0 else 1 end
    as components_measured
  , EndoTrachFlag
  from gcs gs
)
select
  gs.subject_id
  , gs.stay_id
  , gs.charttime
  , GCS AS gcs
  , GCSMotor AS gcs_motor
  , GCSVerbal AS gcs_verbal
  , GCSEyes AS gcs_eyes
  , EndoTrachFlag AS gcs_unable
from gcs_stg gs
;
