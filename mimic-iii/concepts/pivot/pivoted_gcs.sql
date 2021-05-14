-- This query extracts the Glasgow Coma Scale, a measure of neurological function.
-- The query has a few special rules:
--    (1) The verbal component can be set to 0 if the patient is ventilated.
--    This is corrected to 5 - the overall GCS is set to 15 in these cases.
--    (2) Often only one of three components is documented. The other components
--    are carried forward.

-- ITEMIDs used:

-- CAREVUE
--    723 as gcsverbal
--    454 as gcsmotor
--    184 as gcseyes

-- METAVISION
--    223900 GCS - Verbal Response
--    223901 GCS - Motor Response
--    220739 GCS - Eye Opening

-- The code combines the ITEMIDs into the carevue itemids, then pivots those
-- So 223900 is changed to 723, then the ITEMID 723 is pivoted to form gcsverbal

-- Note:
--  The GCS for sedated patients is defaulted to 15 in this code.
--  This is in line with how the data is meant to be collected.
--  e.g., from the SAPS II publication:
--    For sedated patients, the Glasgow Coma Score before sedation was used.
--    This was ascertained either from interviewing the physician who ordered the sedation,
--    or by reviewing the patient's medical record.

with base as
(
  select ce.icustay_id, ce.charttime
  -- pivot each value into its own column
  , max(case when ce.ITEMID in (454,223901) then ce.valuenum else null end) as gcsmotor
  , max(case
      when ce.ITEMID = 723 and ce.VALUE = '1.0 ET/Trach' then 0
      when ce.ITEMID = 223900 and ce.VALUE = 'No Response-ETT' then 0
      when ce.ITEMID in (723,223900) then ce.valuenum
      else null 
    end) as gcsverbal
  , max(case when ce.ITEMID in (184,220739) then ce.valuenum else null end) as gcseyes
  -- convert the data into a number, reserving a value of 0 for ET/Trach
  , max(case
      -- endotrach/vent is assigned a value of 0, later parsed specially
      when ce.ITEMID = 723 and ce.VALUE = '1.0 ET/Trach' then 1 -- carevue
      when ce.ITEMID = 223900 and ce.VALUE = 'No Response-ETT' then 1 -- metavision
    else 0 end)
    as endotrachflag
  , ROW_NUMBER ()
          OVER (PARTITION BY ce.icustay_id ORDER BY ce.charttime ASC) as rn
  FROM `physionet-data.mimiciii_clinical.chartevents` ce
  -- Isolate the desired GCS variables
  where ce.ITEMID in
  (
    -- 198 -- GCS
    -- GCS components, CareVue
    184, 454, 723
    -- GCS components, Metavision
    , 223900, 223901, 220739
  )
  -- exclude rows marked as error
  AND (ce.error IS NULL OR ce.error != 1)
  group by ce.icustay_id, ce.charttime
)
, gcs_stg0 as (
  select b.*
  , b2.gcsverbal as gcsverbalprev
  , b2.gcsmotor as gcsmotorprev
  , b2.gcseyes as gcseyesprev
  -- Calculate GCS, factoring in special case when they are intubated and prev vals
  -- note that the coalesce are used to implement the following if:
  --  if current value exists, use it
  --  if previous value exists, use it
  --  otherwise, default to normal
  , case
      -- replace GCS during sedation with 15
      when b.gcsverbal = 0
        then 15
      when b.gcsverbal is null and b2.gcsverbal = 0
        then 15
      -- if previously they were intub, but they aren't now, do not use previous GCS values
      when b2.gcsverbal = 0
        then
            coalesce(b.gcsmotor,6)
          + coalesce(b.gcsverbal,5)
          + coalesce(b.gcseyes,4)
      -- otherwise, add up score normally, imputing previous value if none available at current time
      else
            coalesce(b.gcsmotor,coalesce(b2.gcsmotor,6))
          + coalesce(b.gcsverbal,coalesce(b2.gcsverbal,5))
          + coalesce(b.gcseyes,coalesce(b2.gcseyes,4))
      end as gcs

  from base b
  -- join to itself within 6 hours to get previous value
  left join base b2
    on b.icustay_id = b2.icustay_id
    and b.rn = b2.rn+1
    and b2.charttime > DATETIME_SUB(b.charttime, INTERVAL 6 HOUR)
)
-- combine components with previous within 6 hours
-- filter down to cohort which is not excluded
-- truncate charttime to the hour
, gcs_stg1 as
(
  select gs.icustay_id, gs.charttime
  , gs.gcs
  , coalesce(gcsmotor,gcsmotorprev) as gcsmotor
  , coalesce(gcsverbal,gcsverbalprev) as gcsverbal
  , coalesce(gcseyes,gcseyesprev) as gcseyes
  , case when coalesce(gcsmotor,gcsmotorprev) is null then 0 else 1 end
  + case when coalesce(gcsverbal,gcsverbalprev) is null then 0 else 1 end
  + case when coalesce(gcseyes,gcseyesprev) is null then 0 else 1 end
    as components_measured
  , endotrachflag
  from gcs_stg0 gs
)
-- priority is:
--  (i) complete data, (ii) non-sedated GCS, (iii) lowest GCS, (iv) charttime
, gcs_priority as
(
  select icustay_id
    , charttime
    , gcs
    , gcsmotor
    , gcsverbal
    , gcseyes
    , endotrachflag
    , ROW_NUMBER() over
      (
        PARTITION BY icustay_id, charttime
        ORDER BY components_measured DESC, endotrachflag, gcs, charttime DESC
      ) as rn
  from gcs_stg1
)
select icustay_id
  , charttime
  , gcs
  , gcsmotor
  , gcsverbal
  , gcseyes
  , endotrachflag
from gcs_priority gs
where rn = 1
ORDER BY icustay_id, charttime;
