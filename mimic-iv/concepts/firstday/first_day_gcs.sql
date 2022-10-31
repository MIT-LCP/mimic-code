-- Glasgow Coma Scale, a measure of neurological function.
-- Ranges from 3 (worst, comatose) to 15 (best, normal function).

-- Note:
-- The GCS for sedated patients is defaulted to 15 in this code.
-- This follows common practice for scoring patients with severity of illness scores.
--
--  e.g., from the SAPS II publication:
--    For sedated patients, the Glasgow Coma Score before sedation was used.
--    This was ascertained either from interviewing the physician who ordered the sedation,
--    or by reviewing the patient's medical record.

WITH gcs_final AS
(
    SELECT
        gcs.*
        -- This sorts the data by GCS
        -- rn = 1 is the the lowest total GCS value
        , ROW_NUMBER () OVER
        (
            PARTITION BY gcs.stay_id
            ORDER BY gcs.GCS
        ) as gcs_seq
    FROM `physionet-data.mimiciv_derived.gcs` gcs
)
SELECT
    ie.subject_id
    , ie.stay_id
    -- The minimum GCS is determined by the above row partition
    -- we only join if gcs_seq = 1
    , gcs AS gcs_min
    , gcs_motor
    , gcs_verbal
    , gcs_eyes
    , gcs_unable
FROM `physionet-data.mimiciv_icu.icustays` ie
LEFT JOIN gcs_final gs
    ON ie.stay_id = gs.stay_id
    AND gs.gcs_seq = 1
;
