WITH s1 as 
(
  SELECT 
    sofa.* 
    , soi.subject_id
    , soi.ab_id
    , soi.antibiotic
    , soi.antibiotic_time
    , soi.culture_time
    , soi.suspected_infection
    , soi.suspected_infection_time
    , soi.specimen
    , soi.positive_culture
  FROM `physionet-data.mimic_derived.suspicion_of_infection` as soi
  INNER JOIN `physionet-data.mimic_derived.sofa` as sofa
    ON soi.stay_id = sofa.stay_id 
    AND sofa.endtime >= DATETIME_SUB(soi.suspected_infection_time, INTERVAL 48 HOUR)
    AND sofa.endtime <= DATETIME_ADD(soi.suspected_infection_time, INTERVAL 24 HOUR)
  WHERE sofa.stay_id is not null and soi.stay_id is not null
)
, s2 as 
(
  SELECT distinct 
    stay_id, subject_id
    , suspected_infection
    , suspected_infection_time
    , starttime, endtime
    , respiration_24hours as respiration
    , coagulation_24hours as coagulation
    , liver_24hours as liver
    , cardiovascular_24hours as cardiovascular
    , cns_24hours as cns
    , renal_24hours as renal
    , coalesce(respiration_24hours, 0)
      + coalesce(coagulation_24hours, 0)
      + coalesce(liver_24hours, 0)
      + coalesce(cardiovascular_24hours, 0)
      + coalesce(cns_24hours, 0)
      + coalesce(renal_24hours, 0) as sofa_score
    , coalesce(respiration_24hours, 0)
      + coalesce(coagulation_24hours, 0)
      + coalesce(liver_24hours, 0)
      + coalesce(cardiovascular_24hours, 0)
      + coalesce(cns_24hours, 0)
      + coalesce(renal_24hours, 0) >= 2 
      and suspected_infection = 1 as sepsis3
  FROM s1
)
, s3 as 
(
  SELECT 
    *, ROW_NUMBER() OVER (PARTITION BY stay_id, suspected_infection_time ORDER BY stay_id, suspected_infection_time, starttime) as infection_rn
  FROM s2
  WHERE sepsis3
)
SELECT 
subject_id, stay_id
, suspected_infection_time
-- endtime is latest time at which the SOFA score is valid
, endtime as sofa_time
, sofa_score
, sepsis3
, respiration, coagulation, liver, cardiovascular, cns, renal
FROM s3
WHERE infection_rn = 1
