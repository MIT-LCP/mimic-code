
-- generate a row for every hour the patient was in the ICU
WITH co_hours AS
(
  select ih.icustay_id, ie.hadm_id
  , hr
  -- start/endtime can be used to filter to values within this hour
  , DATETIME_SUB(ih.endtime, INTERVAL '1' HOUR) AS starttime
  , ih.endtime
  from `physionet-data.mimiciii_derived.icustay_hours` ih
  INNER JOIN `physionet-data.mimiciii_clinical.icustays` ie
    ON ih.icustay_id = ie.icustay_id
)
, mini_agg as
(
  select co.icustay_id, co.hr
  -- vitals
  , min(v.HeartRate) as HeartRate_min
  , max(v.HeartRate) as HeartRate_max
  , min(v.TempC) as TempC_min
  , max(v.TempC) as TempC_max
  , min(v.MeanBP) as MeanBP_min
  , max(v.MeanBP) as MeanBP_max
  , min(v.RespRate) as RespRate_min
  , max(v.RespRate) as RespRate_max
  -- gcs
  , min(gcs.GCS) as GCS_min
  -- because pafi has an interaction between vent/PaO2:FiO2, we need two columns for the score
  -- it can happen that the lowest unventilated PaO2/FiO2 is 68, but the lowest ventilated PaO2/FiO2 is 120
  -- in this case, the SOFA score is 3, *not* 4.
  , MAX(case
        when vd1.icustay_id is not null then 1 
        when vd2.icustay_id is not null then 1
    else 0 end) AS mechvent
  from co_hours co
  left join `physionet-data.mimiciii_derived.pivoted_vital` v
    on co.icustay_id = v.icustay_id
    and co.starttime < v.charttime
    and co.endtime >= v.charttime
  left join `physionet-data.mimiciii_derived.pivoted_gcs` gcs
    on co.icustay_id = gcs.icustay_id
    and co.starttime < gcs.charttime
    and co.endtime >= gcs.charttime
  -- at the time of this row, was the patient ventilated
  left join `physionet-data.mimiciii_derived.ventilation_durations` vd1
    on co.icustay_id = vd1.icustay_id
    and co.starttime >= vd1.starttime
    and co.starttime <= vd1.endtime
  left join `physionet-data.mimiciii_derived.ventilation_durations` vd2
    on co.icustay_id = vd2.icustay_id
    and co.endtime >= vd2.starttime
    and co.endtime <= vd2.endtime
  group by co.icustay_id, co.hr
)
-- sum uo separately to prevent duplicating values
, uo as
(
  select co.icustay_id, co.hr
  -- uo
  , sum(uo.urineoutput) as urineoutput
  from co_hours co
  left join `physionet-data.mimiciii_derived.pivoted_uo` uo
    on co.icustay_id = uo.icustay_id
    and co.starttime < uo.charttime
    and co.endtime >= uo.charttime
  group by co.icustay_id, co.hr
)
, surgflag as
(
  select ie.icustay_id
    , max(case
        when lower(curr_service) like '%surg%' then 1
        when curr_service = 'ORTHO' then 1
    else 0 end) as surgical
  FROM `physionet-data.mimiciii_clinical.icustays` ie
  left join `physionet-data.mimiciii_clinical.services` se
    on ie.hadm_id = se.hadm_id
    and se.transfertime < DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
  group by ie.icustay_id
)
, scorecomp as
(
  select
      co.icustay_id
    , co.hr
    , co.starttime, co.endtime
    , ma.meanbp_min
    , ma.meanbp_max
    , ma.heartrate_min
    , ma.heartrate_max
    , ma.tempc_min
    , ma.tempc_max
    , ma.resprate_min
    , ma.resprate_max
    , ma.gcs_min
    , ma.mechvent
    -- uo
    , uo.urineoutput
    -- static variables that do not change over the ICU stay
    , DATETIME_DIFF(ie.intime, pt.dob, YEAR) AS age
    , DATETIME_DIFF(ie.intime, adm.admittime, SECOND) as preiculos
    , case
        when adm.ADMISSION_TYPE = 'ELECTIVE' and sf.surgical = 1
        then 1
        when adm.ADMISSION_TYPE is null or sf.surgical is null
        then null
        else 0
    end as electivesurgery
  from co_hours co
  inner join `physionet-data.mimiciii_clinical.admissions` adm
    on co.hadm_id = adm.hadm_id
  inner join `physionet-data.mimiciii_clinical.icustays` ie
    on co.icustay_id = ie.icustay_id
  inner join `physionet-data.mimiciii_clinical.patients` pt
    on adm.subject_id = pt.subject_id
  left join surgflag sf
    on co.icustay_id = sf.icustay_id
  left join mini_agg ma
    on co.icustay_id = ma.icustay_id
    and co.hr = ma.hr
  left join uo
    on co.icustay_id = uo.icustay_id
    and co.hr = uo.hr
)
, scorecalc as
(
  -- Calculate the final score
  -- note that if the underlying data is missing, the component is null
  -- eventually these are treated as 0 (normal), but knowing when data is missing is useful for debugging
  select scorecomp.*
    -- Below code calculates the component scores needed for OASIS
    , case when preiculos is null then null
        when preiculos <     612 then 5   -- 0 00:10:12
        when preiculos <   17820 then 3   -- 0 04:57:00
        when preiculos <   86400 then 0   -- 1 day
        when preiculos < 1123680 then 1   -- 12 23:48:00
        else 2 end as preiculos_score
    ,  case when age is null then null
        when age < 24 then 0
        when age <= 53 then 3
        when age <= 77 then 6
        when age <= 89 then 9
        when age >= 90 then 7
        else 0 end as age_score
    ,  case when gcs_min is null then null
        when gcs_min <= 7 then 10
        when gcs_min < 14 then 4
        when gcs_min = 14 then 3
        else 0 end as gcs_score
    ,  case when heartrate_max is null then null
        when heartrate_max > 125 then 6
        when heartrate_min < 33 then 4
        when heartrate_max >= 107 and heartrate_max <= 125 then 3
        when heartrate_max >= 89 and heartrate_max <= 106 then 1
        else 0 end as heartrate_score
    ,  case when meanbp_min is null then null
        when meanbp_min < 20.65 then 4
        when meanbp_min < 51 then 3
        when meanbp_max > 143.44 then 3
        when meanbp_min >= 51 and meanbp_min < 61.33 then 2
        else 0 end as meanbp_score
    ,  case when resprate_min is null then null
        when resprate_min <   6 then 10
        when resprate_max >  44 then  9
        when resprate_max >  30 then  6
        when resprate_max >  22 then  1
        when resprate_min <  13 then 1 else 0
        end as resprate_score
    ,  case when tempc_max is null then null
        when tempc_max > 39.88 then 6
        when tempc_min >= 33.22 and tempc_min <= 35.93 then 4
        when tempc_max >= 33.22 and tempc_max <= 35.93 then 4
        when tempc_min < 33.22 then 3
        when tempc_min > 35.93 and tempc_min <= 36.39 then 2
        when tempc_max >= 36.89 and tempc_max <= 39.88 then 2
        else 0 end as temp_score
    ,  case 
        when SUM(urineoutput) OVER W is null then null
        when SUM(urineoutput) OVER W < 671.09 then 10
        when SUM(urineoutput) OVER W > 6896.80 then 8
        when SUM(urineoutput) OVER W >= 671.09
        and SUM(urineoutput) OVER W <= 1426.99 then 5
        when SUM(urineoutput) OVER W >= 1427.00
        and SUM(urineoutput) OVER W <= 2544.14 then 1
        else 0 end as urineoutput_score
    ,  case when mechvent is null then null
        when mechvent = 1 then 9
        else 0 end as mechvent_score
    ,  case when electivesurgery is null then null
        when electivesurgery = 1 then 0
        else 6 end as electivesurgery_score
  from scorecomp
  WINDOW W as
  (
    PARTITION BY icustay_id
    ORDER BY hr
    ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING
  )
)
, score_final as
(
  select s.*
    -- Look for the worst instantaneous score over the last 24 hours
    -- Impute 0 if the score is missing
    , preiculos_score AS preiculos_score_24hours
    , electivesurgery_score as electivesurgery_score_24hours
    , CAST(coalesce(MAX(age_score) OVER W, 0) AS SMALLINT) as age_score_24hours
    , CAST(coalesce(MAX(gcs_score) OVER W, 0) AS SMALLINT) as gcs_score_24hours
    , CAST(coalesce(MAX(heartrate_score) OVER W, 0) AS SMALLINT) as heartrate_score_24hours
    , CAST(coalesce(MAX(meanbp_score) OVER W,0) AS SMALLINT) as meanbp_score_24hours
    , CAST(coalesce(MAX(resprate_score) OVER W,0) AS SMALLINT) as resprate_score_24hours
    , CAST(coalesce(MAX(temp_score) OVER W,0) AS SMALLINT) as temp_score_24hours
    , CAST(coalesce(MAX(urineoutput_score) OVER W,0) AS SMALLINT) as urineoutput_score_24hours
    , CAST(coalesce(MAX(mechvent_score) OVER W,0) AS SMALLINT) as mechvent_score_24hours

    -- sum together data for final OASIS
    , CAST((preiculos_score
    + electivesurgery_score
    + coalesce(MAX(age_score) OVER W, 0)
    + coalesce(MAX(gcs_score) OVER W, 0)
    + coalesce(MAX(heartrate_score) OVER W, 0)
    + coalesce(MAX(meanbp_score) OVER W,0)
    + coalesce(MAX(resprate_score) OVER W,0)
    + coalesce(MAX(temp_score) OVER W,0)
    + coalesce(MAX(urineoutput_score) OVER W,0)
    + coalesce(MAX(mechvent_score) OVER W,0)
    ) AS SMALLINT)
    as OASIS_24hours
  from scorecalc s
  WINDOW W as
  (
    PARTITION BY icustay_id
    ORDER BY hr
    ROWS BETWEEN 23 PRECEDING AND 0 FOLLOWING
  )
)
select * from score_final
where hr >= 0
;