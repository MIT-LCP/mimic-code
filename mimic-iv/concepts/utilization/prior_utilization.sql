-- -------------------------------------------------------------------------
-- Query: Prior Healthcare Utilization
-- Description:
--   This query calculates the number of prior Emergency Department (ED) visits
--   and inpatient admissions within a specified time window before each
--   current hospital admission. It helps assess the patient's healthcare
--   utilization history prior to the current admission.
--
-- Instructions:
--   - Set the desired time window in days by modifying the `time_window_days`
--     value in the `parameters` CTE (Common Table Expression).
--   - The default time window is 365 days (one year).
--
-- Notes:
--   - The query uses the `admissions` table for inpatient admissions and the
--     `transfers` table for ED visits.
--   - Only prior admissions and ED visits occurring before the current
--     admission are counted.
-- -------------------------------------------------------------------------

WITH parameters AS (
  SELECT 365 AS time_window_days  -- Modify this value to set the time window in days
),

current_admissions AS (
  SELECT
    subject_id,
    hadm_id,
    admittime,
    dischtime
  FROM
    `physionet-data.mimiciv_hosp.admissions`
),

-- Calculate prior inpatient admissions
prior_inpatient_admissions AS (
  SELECT
    ca.subject_id,
    ca.hadm_id AS current_hadm_id,
    COUNT(DISTINCT pa.hadm_id) AS prior_inpatient_count
  FROM
    current_admissions ca
  CROSS JOIN
    parameters p
  LEFT JOIN
    `physionet-data.mimiciv_hosp.admissions` pa
    ON ca.subject_id = pa.subject_id
    AND pa.admittime < ca.admittime
    AND pa.admittime >= TIMESTAMP_SUB(ca.admittime, INTERVAL p.time_window_days DAY)
    AND pa.hadm_id != ca.hadm_id  -- Exclude the current admission
  GROUP BY
    ca.subject_id,
    ca.hadm_id
),

-- Calculate prior ED visits
prior_ed_visits AS (
  SELECT
    ca.subject_id,
    ca.hadm_id AS current_hadm_id,
    COUNT(DISTINCT t.transfer_id) AS prior_ed_count
  FROM
    current_admissions ca
  CROSS JOIN
    parameters p
  LEFT JOIN
    `physionet-data.mimiciv_hosp.transfers` t
    ON ca.subject_id = t.subject_id
    AND t.eventtype = 'ED'
    AND t.intime < ca.admittime
    AND t.intime >= TIMESTAMP_SUB(ca.admittime, INTERVAL p.time_window_days DAY)
    AND (t.hadm_id IS NULL OR t.hadm_id != ca.hadm_id)  -- Exclude EDs within the same admission
  GROUP BY
    ca.subject_id,
    ca.hadm_id
),

-- Combine prior inpatient admissions and prior ED visits
prior_utilization AS (
  SELECT
    ca.subject_id,
    ca.hadm_id,
    ca.admittime,
    ca.dischtime,
    COALESCE(pia.prior_inpatient_count, 0) AS prior_inpatient_count,
    COALESCE(pev.prior_ed_count, 0) AS prior_ed_count
  FROM
    current_admissions ca
  LEFT JOIN
    prior_inpatient_admissions pia
    ON ca.subject_id = pia.subject_id
    AND ca.hadm_id = pia.current_hadm_id
  LEFT JOIN
    prior_ed_visits pev
    ON ca.subject_id = pev.subject_id
    AND ca.hadm_id = pev.current_hadm_id
)

SELECT
  subject_id,
  hadm_id,
  admittime,
  dischtime,
  prior_inpatient_count,
  prior_ed_count
FROM
  prior_utilization
ORDER BY
  subject_id,
  hadm_id;
