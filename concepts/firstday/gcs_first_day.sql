-- ITEMIDs used:

-- CAREVUE
--    723 as GCSVerbal
--    454 as GCSMotor
--    184 as GCSEyes

-- METAVISION
--    223900 GCS - Verbal Response
--    223901 GCS - Motor Response
--    220739 GCS - Eye Opening

-- The code combines the ITEMIDs into the carevue itemids, then pivots those
-- So 223900 is changed to 723, then the ITEMID 723 is pivoted to form GCSVerbal

-- Note:
--  The GCS for sedated patients is defaulted to 15 in this code.
--  This is in line with how the data is meant to be collected.
--  e.g., from the SAPS II publication:
--    For sedated patients, the Glasgow Coma Score before sedation was used.
--    This was ascertained either from interviewing the physician who ordered the sedation,
--    or by reviewing the patient's medical record.

WITH base AS (
    WITH pvt AS (
        SELECT
            stay_id
            , itemid
            , CASE
                -- convert the data into a number, reserving a value of 0 for ET/Trach
                -- endotrach/vent is assigned a value of 0, later parsed specially
                WHEN l.itemid = 223900 AND l.value = 'No Response-ETT' then 0 
                ELSE valuenum
            END as valuenum
            , l.CHARTTIME
        FROM `physionet-data.mimic_icu.chartevents` l
        -- get intime for charttime subselection
        INNER JOIN `physionet-data.mimic_icu.icustays` b USING (stay_id)
        -- Isolate the desired GCS variables
        WHERE
            l.itemid IN (223900, 223901, 220739) -- GCS components, Metavision
            -- Only get data for the first 24 hours
            AND l.charttime BETWEEN b.intime AND DATETIME_ADD(b.intime, INTERVAL '1' DAY)  
    )
    SELECT
        pvt.stay_id
        , pvt.charttime
        -- Easier names - note we coalesced Metavision and CareVue IDs below
        , MAX(CASE WHEN pvt.itemid = 223901 THEN pvt.valuenum END) as GCSMotor
        , MAX(CASE WHEN pvt.itemid = 223900 THEN pvt.valuenum END) as GCSVerbal
        , MAX(CASE WHEN pvt.itemid = 220739 THEN pvt.valuenum END) as GCSEyes
          -- If verbal was set to 0 in the below select, then this is an intubated patient
        , CASE WHEN MAX(CASE WHEN pvt.itemid = 223900 THEN pvt.valuenum END) = 0 THEN 1 ELSE 0 END AS EndoTrachFlag
        , ROW_NUMBER () OVER (PARTITION BY pvt.stay_id ORDER BY pvt.charttime ASC) AS rn
    FROM pvt
    GROUP BY pvt.stay_id, pvt.charttime
), gcs as (
    SELECT
    b.*
    , b2.GCSVerbal as GCSVerbalPrev
    , b2.GCSMotor as GCSMotorPrev
    , b2.GCSEyes as GCSEyesPrev
    -- Calculate GCS, factoring in special case when they are intubated and prev vals
    -- note that the COALESCE are used to implement the following if:
    --  if current value exists, use it
    --  if previous value exists, use it
    --  otherwise, default to normal
    , CASE
        -- replace GCS during sedation with 15
        WHEN b.GCSVerbal = 0 THEN 15
        WHEN b.GCSVerbal IS NULL AND b2.GCSVerbal = 0 THEN 15
        -- if previously they were intub, but they aren't now, do not use previous GCS values
        WHEN b2.GCSVerbal = 0 THEN COALESCE(b.GCSMotor,6) + COALESCE(b.GCSVerbal,5) + COALESCE(b.GCSEyes,4)
        -- otherwise, add up score normally, imputing previous value if none available at current time
        ELSE COALESCE(b.GCSMotor,COALESCE(b2.GCSMotor,6))
            + COALESCE(b.GCSVerbal,COALESCE(b2.GCSVerbal,5))
            + COALESCE(b.GCSEyes,COALESCE(b2.GCSEyes,4))
        END AS GCS
    FROM base b
    -- join to itself within 6 hours to get previous value
    LEFT JOIN base b2 ON
        b.stay_id = b2.stay_id
        AND b.rn = b2.rn+1
        AND b2.charttime > DATETIME_SUB(b.charttime, INTERVAL '6' HOUR)
), gcs_final AS (
    SELECT
        gcs.*
        -- This sorts the data by GCS, so rn=1 is the the lowest GCS values to keep
        , ROW_NUMBER () OVER (PARTITION BY gcs.stay_id ORDER BY gcs.GCS) as IsMinGCS
    FROM gcs
)
SELECT
    ie.subject_id
    , ie.hadm_id
    , ie.stay_id
    -- The minimum GCS is determined by the above row partition, we only join if IsMinGCS=1
    , GCS as mingcs
    , COALESCE(GCSMotor,GCSMotorPrev) as gcsmotor
    , COALESCE(GCSVerbal,GCSVerbalPrev) as gcsverbal
    , COALESCE(GCSEyes,GCSEyesPrev) as gcseyes
    , EndoTrachFlag as endotrachflag
    -- subselect down to the cohort of eligible patients
FROM `physionet-data.mimic_icu.icustays` ie
LEFT JOIN gcs_final gs ON
    ie.stay_id = gs.stay_id
    AND gs.IsMinGCS = 1
ORDER BY ie.stay_id;

