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
  FROM `lcp-internal.sepsis_test.suspicion_of_infection` as soi
  INNER JOIN `lcp-internal.sepsis_test.sofa` as sofa
    ON soi.stay_id = sofa.stay_id 
    AND sofa.starttime >= DATETIME_SUB(soi.suspected_infection_time, INTERVAL 48 HOUR)
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
    , respiration
    , coagulation
    , liver
    , cardiovascular
    , cns
    , renal
    , coalesce(respiration, 0)
      + coalesce(coagulation, 0)
      + coalesce(liver, 0)
      + coalesce(cardiovascular, 0)
      + coalesce(cns, 0)
      + coalesce(renal, 0) as sofa_score
    , coalesce(respiration, 0)
      + coalesce(coagulation, 0)
      + coalesce(liver, 0)
      + coalesce(cardiovascular, 0)
      + coalesce(cns, 0)
      + coalesce(renal, 0) >= 2 
      and suspected_infection = 1 as sepsis3
  FROM s1
)
, s3 as 
(
  SELECT 
    *, ROW_NUMBER() OVER (PARTITION BY stay_id, suspected_infection_time ORDER BY stay_id, suspected_infection_time, starttime) as rn
  FROM s2
  WHERE sepsis3
)
SELECT * FROM s3
WHERE rn = 1