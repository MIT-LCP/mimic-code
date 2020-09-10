-- note this duplicates prescriptions
-- each ICU stay in the same hospitalization will get a copy of all prescriptions for that hospitalization
WITH ab_tbl AS 
(
  select
      abx.subject_id, abx.hadm_id, abx.stay_id
    , abx.antibiotic
    , abx.starttime AS antibiotic_time
    , abx.stoptime AS antibiotic_stoptime
    -- create a unique identifier for each patient antibiotic
    , ROW_NUMBER() OVER
    (
      PARTITION BY stay_id
      ORDER BY starttime, stoptime, antibiotic
    ) AS ab_id
  from (
    SELECT * FROM `physionet-data.mimic_derived.antibiotic`
    WHERE stay_id is not null
  ) abx
)
, me as
(
  select micro_specimen_id
    -- the following columns are identical for all rows of the same micro_specimen_id
    -- these aggregates simply collapse duplicates down to 1 row
    , MAX(subject_id) AS subject_id
    , MAX(hadm_id) AS hadm_id
    , MAX(chartdate) AS chartdate
    , MAX(charttime) AS charttime
    , MAX(spec_type_desc) AS spec_type_desc
    , max(case when org_name is not null and org_name != '' then 1 else 0 end) as PositiveCulture
  from `physionet-data.mimic_hosp.microbiologyevents`
  group by micro_specimen_id
)
-- culture followed by an antibiotic
, me_then_ab AS
(
  select
    ab_tbl.subject_id
    , ab_tbl.hadm_id
    , ab_tbl.stay_id
    , ab_tbl.ab_id
    
    , me72.micro_specimen_id
    , coalesce(me72.charttime, me72.chartdate) as last72_charttime
    , me72.positiveculture as last72_positiveculture
    , me72.spec_type_desc as last72_specimen
  from ab_tbl
  -- abx taken after culture, but no more than 72 hours after
  left join me me72
    on ab_tbl.subject_id = me72.subject_id
    and
    (
      (
      -- if charttime is available, use it
          me72.charttime is not null
      and ab_tbl.antibiotic_time > me72.charttime
      and ab_tbl.antibiotic_time <= DATETIME_ADD(me72.charttime, INTERVAL 72 HOUR) 
      )
      OR
      (
      -- if charttime is not available, use chartdate
          me72.charttime is null
      and ab_tbl.antibiotic_time > me72.chartdate
      -- note we do 96 hours to include abx on the 3rd day
      -- this is to handle the truncated date in chartdate
      and ab_tbl.antibiotic_time <= DATETIME_ADD(me72.chartdate, INTERVAL 72 HOUR) 
      )
    )
)
, ab_then_me AS
(
  select
      ab_tbl.subject_id
    , ab_tbl.hadm_id
    , ab_tbl.stay_id
    , ab_tbl.ab_id
    
    , me24.micro_specimen_id
    , coalesce(me24.charttime, me24.chartdate) as next24_charttime
    , me24.positiveculture as next24_positiveculture
    , me24.spec_type_desc as next24_specimen
  from ab_tbl
  -- culture in subsequent 24 hours
  left join me me24
    on ab_tbl.subject_id = me24.subject_id
    and
    (
      (
          -- if charttime is available, use it
          me24.charttime is not null
      and ab_tbl.antibiotic_time >= DATETIME_SUB(me24.charttime, INTERVAL 24 HOUR)  
      and ab_tbl.antibiotic_time < me24.charttime
      )
      OR
      (
          -- if charttime is not available, use chartdate
          me24.charttime is null
      and ab_tbl.antibiotic_time > DATETIME_SUB(me24.chartdate, INTERVAL 24 HOUR)  
      and ab_tbl.antibiotic_time < me24.chartdate
      )
    )
)
SELECT
ab_tbl.subject_id
, ab_tbl.stay_id
, ab_tbl.hadm_id
, ab_tbl.ab_id
, ab_tbl.antibiotic
, ab_tbl.antibiotic_time

, CASE
  WHEN ab2me.ab_id IS NULL AND me2ab.ab_id IS NULL
    THEN 0
  ELSE 1 
  END AS suspected_infection
-- time of suspected infection:
--    (1) the culture time (if before antibiotic)
--    (2) or the antibiotic time (if before culture)
, CASE
  WHEN ab2me.ab_id IS NULL AND me2ab.ab_id IS NULL
    THEN NULL
  ELSE COALESCE(last72_charttime, antibiotic_time)
  END AS suspected_infection_time

, COALESCE(last72_charttime, next24_charttime) AS culture_time

-- the specimen that was cultured
, COALESCE(last72_specimen, next24_specimen) AS specimen

-- whether the cultured specimen ended up being positive or not
, COALESCE(last72_positiveculture, next24_positiveculture) AS positiveculture

FROM ab_tbl
LEFT JOIN ab_then_me ab2me
  USING(subject_id, stay_id, hadm_id, ab_id)
LEFT JOIN me_then_ab me2ab
  USING(subject_id, stay_id, hadm_id, ab_id)
;
