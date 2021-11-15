-- ------------------------------------------------------------------
-- Title: Lab results related to heart failure.
-- Description: This query extracts NT-proB-type Natriuretic Peptide lab results from blood samples. It looks for the latest available result in the eletronic medical record. NT-proBNP is strongly related to heart failure as a screening tool to differentiate between patients with normal and reduced left ventricular systolic function. 
-- Reference: Bay M, Kirk V, Parner J, et al. NT-proBNP: a new diagnostic screening tool to differentiate between patients with normal and reduced left ventricular systolic function. Heart. 2003;89(2):150-154. doi:10.1136/heart.89.2.150
-- ------------------------------------------------------------------

SELECT
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  , le.specimen_id
  -- convert from itemid into a meaningful column
  , MAX(CASE WHEN itemid = 50963 THEN valuenum ELSE NULL END) AS ntprobnp
FROM mimic_hosp.labevents le
WHERE le.itemid IN
(
    50963 -- ntprobnp
)
AND valuenum IS NOT NULL
-- lab values cannot be 0 and cannot be negative
AND valuenum > 0
GROUP BY le.specimen_id
;