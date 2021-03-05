-------------------------------------------------------------------------------------
--Title: generates a row for every hospital admission per patient to describe the counts of their clinical notes.
--The statement was created for postgresql and it utilizes a function called crosstab from the tablefunc extension in postgresql. 
--First we add the extension tablefunc to allow us to use the crosstab function in line 10 
--The statement will show the count and the type of clinical notes written for each patient in each hospital admission.
--The prerequisite for this statement is to create  the extension of tablefunc in which we can find crosstab() function.
-- Notes: this query does not specify a schema. To run it on your local
-- MIMIC schema, run the following command:
--  SET SEARCH_PATH TO mimiciii;
-- Where "mimiciii" is the name of your schema, and may be different.
----------------------------------------------------------------------------------------------

CREATE EXTENSION IF NOT EXISTS tablefunc;
CREATE VIEW note_counts AS
  WITH groupnotes AS (
      SELECT
        ct.hadm_id,
        ct.case_management,
        ct.consult,
        ct.discharge_summary,
        ct.ecg,
        ct.echo,
        ct.general,
        ct.nursing,
        ct.nursing_other,
        ct.nutrition,
        ct.pharmacy,
        ct.physician,
        ct.radiology,
        ct.rehab_services,
        ct.respiratory,
        ct.social_work
      FROM crosstab(
               'select  noteevents.hadm_id as hadm_id, noteevents.category as note_type, count(noteevents.text) as notes_count FROM `physionet-data.mimiciii_clinical.noteevents` where noteevents.hadm_id is not null GROUP BY noteevents.hadm_id,noteevents.category order by 1,2' :: TEXT,
               'select Distinct noteevents.category FROM `physionet-data.mimiciii_clinical.noteevents` order by 1' :: TEXT) ct(hadm_id INTEGER, case_management INTEGER, consult INTEGER, discharge_summary INTEGER, ecg INTEGER, echo INTEGER, general INTEGER, nursing INTEGER, nursing_other INTEGER, nutrition INTEGER, pharmacy INTEGER, physician INTEGER, radiology INTEGER, rehab_services INTEGER, respiratory INTEGER, social_work INTEGER)
  ), totalnotes AS (
      SELECT
        noteevents.hadm_id,
        count(noteevents.text) AS notes_count
      FROM `physionet-data.mimiciii_clinical.noteevents`
      WHERE (noteevents.hadm_id IS NOT NULL)
      GROUP BY noteevents.hadm_id
      ORDER BY noteevents.hadm_id
  )
  SELECT
    admissions.subject_id,
    admissions.hadm_id,
    (admissions.dischtime - admissions.admittime)                             AS length_of_stay,
    date_part('epoch' :: TEXT, (admissions.dischtime -
                                admissions.admittime))                                   AS length_of_stay_epoch,
    CASE
    WHEN (totalnotes.notes_count IS NULL)
      THEN '0' :: BIGINT
    ELSE totalnotes.notes_count
    END                                                                                             AS total_notes,
    CASE
    WHEN (groupnotes.case_management IS NULL)
      THEN 0
    ELSE groupnotes.case_management
    END                                                                                             AS case_management,
    CASE
    WHEN (groupnotes.consult IS NULL)
      THEN 0
    ELSE groupnotes.consult
    END                                                                                             AS consult,
    CASE
    WHEN (groupnotes.discharge_summary IS NULL)
      THEN 0
    ELSE groupnotes.discharge_summary
    END                                                                                             AS discharge_summary,
    CASE
    WHEN (groupnotes.ecg IS NULL)
      THEN 0
    ELSE groupnotes.ecg
    END                                                                                             AS ecg,
    CASE
    WHEN (groupnotes.echo IS NULL)
      THEN 0
    ELSE groupnotes.echo
    END                                                                                             AS echo,
    CASE
    WHEN (groupnotes.general IS NULL)
      THEN 0
    ELSE groupnotes.general
    END                                                                                             AS general,
    CASE
    WHEN (groupnotes.nursing IS NULL)
      THEN 0
    ELSE groupnotes.nursing
    END                                                                                             AS nursing,
    CASE
    WHEN (groupnotes.nursing_other IS NULL)
      THEN 0
    ELSE groupnotes.nursing_other
    END                                                                                             AS nursing_other,
    CASE
    WHEN (groupnotes.nutrition IS NULL)
      THEN 0
    ELSE groupnotes.nutrition
    END                                                                                             AS nutrition,
    CASE
    WHEN (groupnotes.pharmacy IS NULL)
      THEN 0
    ELSE groupnotes.pharmacy
    END                                                                                             AS pharmacy,
    CASE
    WHEN (groupnotes.physician IS NULL)
      THEN 0
    ELSE groupnotes.physician
    END                                                                                             AS physician,
    CASE
    WHEN (groupnotes.radiology IS NULL)
      THEN 0
    ELSE groupnotes.radiology
    END                                                                                             AS radiology,
    CASE
    WHEN (groupnotes.rehab_services IS NULL)
      THEN 0
    ELSE groupnotes.rehab_services
    END                                                                                             AS rehab_services,
    CASE
    WHEN (groupnotes.respiratory IS NULL)
      THEN 0
    ELSE groupnotes.respiratory
    END                                                                                             AS respiratory,
    CASE
    WHEN (groupnotes.social_work IS NULL)
      THEN 0
    ELSE groupnotes.social_work
    END                                                                                             AS social_work
  FROM `physionet-data.mimiciii_clinical.admissions`
  LEFT JOIN groupnotes
    ON admissions.hadm_id = groupnotes.hadm_id
  LEFT JOIN totalnotes 
    ON admissions.hadm_id = totalnotes.hadm_id
  ORDER BY admissions.subject_id, admissions.hadm_id;

