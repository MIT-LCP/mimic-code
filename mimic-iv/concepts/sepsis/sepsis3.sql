-- Creates a table with "onset" time of Sepsis-3 in the ICU.
-- That is, the earliest time at which a patient had SOFA >= 2 and suspicion of infection.
-- As many variables used in SOFA are only collected in the ICU, this query can only
-- define sepsis-3 onset within the ICU.

-- extract rows with SOFA >= 2
-- implicitly this assumes baseline SOFA was 0 before ICU admission.
WITH sofa AS
(
  SELECT stay_id
    , starttime, endtime
    , respiration_24hours as respiration
    , coagulation_24hours as coagulation
    , liver_24hours as liver
    , cardiovascular_24hours as cardiovascular
    , cns_24hours as cns
    , renal_24hours as renal
    , sofa_24hours as sofa_score
  FROM `physionet-data.mimiciv_derived.sofa`
  WHERE sofa_24hours >= 2
)
, s1 as
(
  SELECT
    soi.subject_id
    , soi.stay_id
    -- suspicion columns
    , soi.ab_id
    , soi.antibiotic
    , soi.antibiotic_time
    , soi.culture_time
    , soi.suspected_infection
    , soi.suspected_infection_time
    , soi.specimen
    , soi.positive_culture
    -- sofa columns
    , starttime, endtime
    , respiration, coagulation, liver, cardiovascular, cns, renal
    , sofa_score
    -- All rows have an associated suspicion of infection event
    -- Therefore, Sepsis-3 is defined as SOFA >= 2.
    -- Implicitly, the baseline SOFA score is assumed to be zero, as we do not know
    -- if the patient has preexisting (acute or chronic) organ dysfunction
    -- before the onset of infection.
    , sofa_score >= 2 and suspected_infection = 1 as sepsis3
    -- subselect to the earliest suspicion/antibiotic/SOFA row
    , ROW_NUMBER() OVER
    (
        PARTITION BY soi.stay_id
        ORDER BY suspected_infection_time, antibiotic_time, culture_time, endtime
    ) AS rn_sus
  FROM `physionet-data.mimiciv_derived.suspicion_of_infection` as soi
  INNER JOIN sofa
    ON soi.stay_id = sofa.stay_id
    AND sofa.endtime >= DATETIME_SUB(soi.suspected_infection_time, INTERVAL '48' HOUR)
    AND sofa.endtime <= DATETIME_ADD(soi.suspected_infection_time, INTERVAL '24' HOUR)
  -- only include in-ICU rows
  WHERE soi.stay_id is not null
)
SELECT
subject_id, stay_id
-- note: there may be more than one antibiotic given at this time
, antibiotic_time
-- culture times may be dates, rather than times
, culture_time
, suspected_infection_time
-- endtime is latest time at which the SOFA score is valid
, endtime as sofa_time
, sofa_score
, respiration, coagulation, liver, cardiovascular, cns, renal
, sepsis3
FROM s1
WHERE rn_sus = 1
