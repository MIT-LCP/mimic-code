-- ------------------------------------------------------------------
-- Title: Calculate in-hospital, 30-day, and 1 year mortality (from hospital admission)
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
-- Inclusion criteria: Adult (>15 year old) patients, *MOST RECENT* hospital admission
-- ------------------------------------------------------------------

WITH tmp as
(
    SELECT adm.hadm_id, admittime, dischtime, adm.deathtime, pat.dod
    FROM `physionet-data.mimiciii_clinical.admissions` adm
    INNER JOIN patients pat
    ON adm.subject_id = pat.subject_id
    -- filter out organ donor accounts
    WHERE lower(diagnosis) NOT LIKE '%organ donor%'
    -- at least 15 years old
    AND DATETIME_DIFF(admittime, dob, YEAR) > 15
    -- filter that removes hospital admissions with no corresponding ICU data
    AND HAS_CHARTEVENTS_DATA = 1
)
SELECT COUNT(hadm_id) AS NumPat -- total number of patients
, round( cast(COUNT(deathtime) AS NUMERIC)/COUNT(hadm_id)*100 , 4) AS HospMort -- % hospital mortality
, round( cast(SUM(CASE WHEN dod < DATETIME_ADD(admittime, INTERVAL 30 DAY) THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(hadm_id)*100.0 , 4) AS HospMort30day -- % 30 day mortality
, round( cast(SUM(CASE WHEN dod < DATETIME_ADD(admittime, INTERVAL 1 YEAR) THEN 1 ELSE 0 END) AS NUMERIC)/COUNT(hadm_id)*100 , 4) AS HospMort1yr -- % 1 year mortality
FROM tmp;
