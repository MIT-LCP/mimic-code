drop table if exists gcs_first_day; create table gcs_first_day as 
-- itemids used:

-- CAREVUE
--    723 as GCSVerbal
--    454 as GCSMotor
--    184 as GCSEyes


-- The code combines the ITEMIDs into the carevue itemids, then pivots those
-- So 223900 is changed to 723, then the ITEMID 723 is pivoted to form GCSVerbal

-- Note:
--  The GCS for sedated patients is defaulted to 15 in this code.
--  This is in line with how the data is meant to be collected.
--  e.g., from the SAPS II publication:
--    For sedated patients, the Glasgow Coma Score before sedation was used.
--    This was ascertained either from interviewing the physician who ordered the sedation,
--    or by reviewing the patient's medical record.

with base as
(
  select pvt.icustay_id
  , pvt.charttime

  -- Easier names - note we coalesced CareVue IDs below
  , max(case when pvt.itemid = 454 then pvt.valuenum else null end) as gcsmotor
  , max(case when pvt.itemid = 723 then pvt.valuenum else null end) as gcsverbal
  , max(case when pvt.itemid = 184 then pvt.valuenum else null end) as gcseyes

  -- If verbal was set to 0 in the below select, then this is an intubated patient
  , case
      when max(case when pvt.itemid = 723 then pvt.valuenum else null end) = 0
    then 1
    else 0
    end as endotrachflag

  , row_number ()
          over (partition by pvt.icustay_id order by pvt.charttime asc) as rn

  from (
  select 
    l.icustay_id
    , itemid

    -- convert the data into a number, reserving a value of 0 for ET/Trach
    , case
      -- endotrach/vent is assigned a value of 0, later parsed specially
      when l.itemid = 723 and l.value = '1.0 ET/Trach' then 0 -- carevue
      else valuenum
      end
    as valuenum
    , l.charttime
  from chartevents l

  -- get intime for charttime subselection
  inner join icustays b
    on l.icustay_id = b.icustay_id

  -- Isolate the desired GCS variables
  where l.itemid in
    (
    -- 198 -- GCS
    -- GCS components, CareVue
    184, 454, 723
    )
    -- Only get data for the first 24 hours
    and l.charttime between b.intime and (b.intime + interval '1 day')
    -- exclude rows marked as error
    and (l.error is null or l.error = 0)
    ) pvt
  group by pvt.icustay_id, pvt.charttime
)
, gcs as (
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
    on b.icustay_id = b2.icustay_id and b.rn = b2.rn+1 and b2.charttime > (b.charttime - interval '6 hour')
)
, gcs_final as (
  select gcs.*
  -- This sorts the data by GCS, so rn=1 is the the lowest GCS values to keep
  , row_number ()
          over (partition by gcs.icustay_id
                order by gcs.gcs
               ) as ismingcs
  from gcs
)
select ie.subject_id, ie.hadm_id, ie.icustay_id
-- The minimum GCS is determined by the above row partition, we only join if IsMinGCS=1
, gcs as mingcs
, coalesce(gcsmotor,gcsmotorprev) as gcsmotor
, coalesce(gcsverbal,gcsverbalprev) as gcsverbal
, coalesce(gcseyes,gcseyesprev) as gcseyes
, endotrachflag as endotrachflag

-- subselect down to the cohort of eligible patients
from icustays ie
left join gcs_final gs
  on ie.icustay_id = gs.icustay_id and gs.ismingcs = 1
order by ie.icustay_id;