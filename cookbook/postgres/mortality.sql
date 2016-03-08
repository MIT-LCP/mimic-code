-- ------------------------------------------------------------------
-- Title: Calculate in-hospital, 30-day, and 1 year mortality (from hospital admission)
-- MIMIC version: ?
-- Inclusion criteria: Adult (>15 year old) patients, *MOST RECENT* hospital admission
-- ------------------------------------------------------------------

WITH tmp as (
    SELECT adm.hadm_id, admittime, dischtime, adm.deathtime, pat.dod
    -- integer which is 1 for the most recent hospital admission
    , ROW_NUMBER() OVER (PARTITION BY hadm_id ORDER BY admittime DESC) AS mostrecent
    FROM admissions adm
    INNER JOIN patients pat
    ON adm.subject_id = pat.subject_id
    -- filter out organ donor accounts
    WHERE lower(diagnosis) NOT LIKE '%organ donor%'
    -- at least 15 years old
    AND extract(YEAR FROM admittime) - extract(YEAR FROM dob) > 15
    -- filter that removes hospital admissions with no corresponding ICU data
    AND HAS_CHARTEVENTS_DATA = 1)
SELECT COUNT(hadm_id) AS NumPat -- total number of patients
, round( COUNT(deathtime)/COUNT(hadm_id)*100 , 4) AS HospMort -- % hospital mortality
, round( SUM(CASE WHEN dod < admittime+30 THEN 1 ELSE 0 END)/COUNT(hadm_id)*100 , 4) AS HospMort30day -- % 30 day mortality
, round( SUM(CASE WHEN dod < admittime+365.25 THEN 1 ELSE 0 END)/COUNT(hadm_id)*100 , 4) AS HospMort1yr -- % 1 year mortality
FROM tmp;
