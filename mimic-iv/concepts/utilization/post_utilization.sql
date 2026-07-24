-- -------------------------------------------------------------------------
-- Query: Post-Discharge Healthcare Utilization with ED Visit Classification
-- Description:
--   This query calculates the number of Emergency Department (ED) visits and
--   inpatient readmissions within a specified time window after each hospital
--   discharge. Additionally, it classifies ED visits based on whether they
--   resulted in an admission ("with admission") or not ("without admission").
--   This helps assess the patient's healthcare utilization following
--   discharge from the hospital, with a distinction between different types of ED visits.
--
-- Instructions:
--   - Set the desired time window in days by modifying the `time_window_days`
--     value in the `parameters` CTE (Common Table Expression).
--   - The default time window is 30 days.
--
-- Notes:
--   - The query uses the `admissions` table for inpatient readmissions and the
--     `transfers` table for ED visits.
--   - Only admissions and ED visits occurring after the current discharge are
--     counted.
--   - ED visits are classified into those that result in an admission and those
--     that do not.
-- -------------------------------------------------------------------------

WITH parameters AS (
  SELECT 30 AS time_window_days  -- Modify this value to set the time window in days
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

-- Calculate post-discharge inpatient readmissions
post_inpatient_readmissions AS (
  SELECT
    ca.subject_id,
    ca.hadm_id AS current_hadm_id,
    COUNT(DISTINCT na.hadm_id) AS post_inpatient_count
  FROM
    current_admissions ca
  CROSS JOIN
    parameters p
  LEFT JOIN
    `physionet-data.mimiciv_hosp.admissions` na
    ON ca.subject_id = na.subject_id
    AND na.admittime > ca.dischtime
    AND na.admittime <= TIMESTAMP_ADD(ca.dischtime, INTERVAL p.time_window_days DAY)
    AND na.hadm_id != ca.hadm_id  -- Exclude the current admission
  GROUP BY
    ca.subject_id,
    ca.hadm_id
),

-- Calculate post-discharge ED visits that do NOT result in admission
post_ed_visits_wo_adm AS (
  SELECT
    ca.subject_id,
    ca.hadm_id AS current_hadm_id,
    COUNT(DISTINCT t.transfer_id) AS post_ed_wo_adm_count
  FROM
    current_admissions ca
  CROSS JOIN
    parameters p
  LEFT JOIN
    `physionet-data.mimiciv_hosp.transfers` t
    ON ca.subject_id = t.subject_id
    AND t.eventtype = 'ED'
    AND t.intime > ca.dischtime
    AND t.intime <= TIMESTAMP_ADD(ca.dischtime, INTERVAL p.time_window_days DAY)
    AND (t.hadm_id IS NULL OR t.hadm_id != ca.hadm_id)  -- Exclude EDs within the same admission
    AND t.hadm_id IS NULL  -- Ensure ED visit did not result in an admission
  GROUP BY
    ca.subject_id,
    ca.hadm_id
),

-- Calculate post-discharge ED visits that result in admission
post_ed_visits_w_adm AS (
  SELECT
    ca.subject_id,
    ca.hadm_id AS current_hadm_id,
    COUNT(DISTINCT t.transfer_id) AS post_ed_w_adm_count
  FROM
    current_admissions ca
  CROSS JOIN
    parameters p
  LEFT JOIN
    `physionet-data.mimiciv_hosp.transfers` t
    ON ca.subject_id = t.subject_id
    AND t.eventtype = 'ED'
    AND t.intime > ca.dischtime
    AND t.intime <= TIMESTAMP_ADD(ca.dischtime, INTERVAL p.time_window_days DAY)
    AND t.hadm_id != ca.hadm_id  -- Exclude EDs within the same admission
    AND t.hadm_id IS NOT NULL  -- Ensure ED visit resulted in an admission
  GROUP BY
    ca.subject_id,
    ca.hadm_id
),

-- Combine post-discharge ED visits
post_ed_visits AS (
  SELECT
    woa.subject_id,
    woa.current_hadm_id,
    COALESCE(woa.post_ed_wo_adm_count, 0) AS post_ed_wo_adm_count,
    COALESCE(wa.post_ed_w_adm_count, 0) AS post_ed_w_adm_count
  FROM
    post_ed_visits_wo_adm woa
  FULL OUTER JOIN
    post_ed_visits_w_adm wa
    ON woa.subject_id = wa.subject_id
    AND woa.current_hadm_id = wa.current_hadm_id
),

-- Combine post-discharge inpatient readmissions and ED visits
post_discharge_utilization AS (
  SELECT
    ca.subject_id,
    ca.hadm_id,
    ca.admittime,
    ca.dischtime,
    COALESCE(pir.post_inpatient_count, 0) AS post_inpatient_count,
    COALESCE(pev.post_ed_wo_adm_count, 0) AS post_ed_wo_adm_count,
    COALESCE(pev.post_ed_w_adm_count, 0) AS post_ed_w_adm_count
  FROM
    current_admissions ca
  LEFT JOIN
    post_inpatient_readmissions pir
    ON ca.subject_id = pir.subject_id
    AND ca.hadm_id = pir.current_hadm_id
  LEFT JOIN
    post_ed_visits pev
    ON ca.subject_id = pev.subject_id
    AND ca.hadm_id = pev.current_hadm_id
)

SELECT
  subject_id,
  hadm_id,
  admittime,
  dischtime,
  post_inpatient_count,
  post_ed_wo_adm_count,
  post_ed_w_adm_count
FROM
  post_discharge_utilization
ORDER BY
  subject_id,
  hadm_id;
