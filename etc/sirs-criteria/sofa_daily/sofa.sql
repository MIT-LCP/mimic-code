-- ------------------------------------------------------------------
-- Original Source: https://github.com/MIT-LCP/mimic-code/blob/401132f256aff1e67161ce94cf0714ac1d344f5c/severityscores/sofa.sql
-- modified to calculate some data without the limitation of the first day 
-- and to get the data of each calendar day
-- ------------------------------------------------------------------

-- Table ECHODATA and ventdurations are available inside the repository

CREATE TABLE a_SOFA AS
with wt AS
(
  SELECT ie.icustay_id
    -- ensure weight is measured in kg
	, avg(CASE 
        WHEN itemid IN (762, 763, 3723, 3580, 226512)
          THEN valuenum
        -- convert lbs to kgs
        WHEN itemid IN (3581)
          THEN valuenum * 0.45359237
        WHEN itemid IN (3582)
          THEN valuenum * 0.0283495231
        ELSE null
      END) AS weight
  from icustays ie
  left join chartevents c
    on ie.icustay_id = c.icustay_id
  WHERE valuenum IS NOT NULL
  AND itemid IN
  (
    762, 763, 3723, 3580,                     -- Weight Kg
    3581,                                     -- Weight lb
    3582,                                     -- Weight oz
    226512 -- Metavision: Admission Weight (Kg)
  )
  AND valuenum != 0
  and charttime between ie.intime - interval '1' day and ie.outtime -- I didn't remove it because of getting AVG (avg should occur in this interval)
  group by ie.icustay_id
)
-- 5% of patients are missing a weight, but we can impute weight using their echo notes
, echo2 as(
  select ie.icustay_id, 
  avg(weight * 0.45359237) as weight --!!! I assumed that weight doesn't change during 8 days
  from icustays ie
  left join echodata echo
    on ie.hadm_id = echo.hadm_id
    and echo.charttime > ie.intime - interval '7' day
    and echo.charttime < ie.outtime
  group by ie.icustay_id
)
, vaso_cv as
(
  select foo.icustay_id
    -- case statement determining whether the ITEMID is an instance of vasopressor usage
    , max(rate_norepinephrine) as rate_norepinephrine
    , max(rate_epinephrine) as rate_epinephrine
    , max(rate_dopamine) as rate_dopamine
    , max(rate_dobutamine) as rate_dobutamine
    , dailyInterval

	from (
		select ie.icustay_id
   			 -- case statement determining whether the ITEMID is an instance of vasopressor usage
    	  , case
     			when itemid = 30047 then rate / coalesce(wt.weight,ec.weight) -- measured in mcgmin
            	when itemid = 30120 then rate -- measured in mcgkgmin ** there are clear errors, perhaps actually mcgmin
            	else null
          	end as rate_norepinephrine

    	  , case
            	when itemid =  30044 then rate / coalesce(wt.weight,ec.weight) -- measured in mcgmin
            	when itemid in (30119,30309) then rate -- measured in mcgkgmin
            	else null
          	end as rate_epinephrine

    	  , case when itemid in (30043,30307) then rate end as rate_dopamine
    	  , case when itemid in (30042,30306) then rate end as rate_dobutamine
 		  , datediff('day', ie.intime::date, cv.charttime::date) AS dailyInterval
	
  		from icustays ie
  		inner join inputevents_cv cv
    	on ie.icustay_id = cv.icustay_id 
  		left join wt
    		on ie.icustay_id = wt.icustay_id
  		left join echo2 ec
    		on ie.icustay_id = ec.icustay_id
  		where itemid in (30047,30120,30044,30119,30309,30043,30307,30042,30306)
  			and rate is not null
  ) as foo
  where dailyInterval < 10
  group by foo.icustay_id, dailyInterval
)
, vaso_mv as
(
  select icustay_id
  	, max(rate_norepinephrine) as rate_norepinephrine
    , max(rate_epinephrine) as rate_epinephrine
    , max(rate_dopamine) as rate_dopamine
    , max(rate_dobutamine) as rate_dobutamine
    , dailyInterval
  	
  	from (
  		select ie.icustay_id
    		-- case statement determining whether the ITEMID is an instance of vasopressor usage
    		, case when itemid = 221906 then rate end as rate_norepinephrine
    		, case when itemid = 221289 then rate end as rate_epinephrine
    		, case when itemid = 221662 then rate end as rate_dopamine
    		, case when itemid = 221653 then rate end as rate_dobutamine
    		, datediff('day', ie.intime::date, mv.starttime::date) AS dailyInterval
  		from icustays ie
  		inner join inputevents_mv mv
   		 	on ie.icustay_id = mv.icustay_id 
  		where itemid in (221906,221289,221662,221653)
  		-- 'Rewritten' orders are not delivered to the patient
  			and statusdescription != 'Rewritten'
  	) AS foo
  where dailyInterval < 10
  group by icustay_id, dailyInterval
)
, pafi1 as
(
  -- join blood gas to ventilation durations to determine if patient was vent
  select bg.icustay_id, bg.charttime
  , PaO2FiO2
  , case when vd.icustay_id is not null then 1 else 0 end as IsVent
  , dailyInterval
  from a_bloodgasaterial bg
  left join ventdurations vd
    on bg.icustay_id = vd.icustay_id
    and bg.charttime >= vd.starttime
    and bg.charttime <= vd.endtime
    where dailyInterval < 10
  order by bg.icustay_id, bg.charttime
)
, pafi2 as
(
  -- because pafi has an interaction between vent/PaO2:FiO2, we need two columns for the score
  -- it can happen that the lowest unventilated PaO2/FiO2 is 68, but the lowest ventilated PaO2/FiO2 is 120
  -- in this case, the SOFA score is 3, *not* 4.
  select icustay_id
  , min(case when IsVent = 0 then PaO2FiO2 else null end) as PaO2FiO2_novent_min
  , min(case when IsVent = 1 then PaO2FiO2 else null end) as PaO2FiO2_vent_min
  , dailyInterval
  from pafi1
  group by icustay_id,dailyInterval
)
, icu_intervals as 
(
select distinct icustay_id, dailyInterval from
	(select icustay_id, dailyInterval from a_gcs 
	union
	select icustay_id, dailyInterval from a_labs
	union
	select icustay_id, dailyInterval from a_bloodgas
	union
	select icustay_id, dailyInterval from a_uo
	union
	select icustay_id, dailyInterval from a_vitals
	union
	select icustay_id, dailyInterval from pafi2
	union
	select icustay_id, dailyInterval from vaso_cv
	union
	select icustay_id, dailyInterval from vaso_mv
	) as foo
)
-- Aggregate the components for the score
, scorecomp as
(
select ie.icustay_id ,ie.dailyInterval
  , MeanBP_Min
  , coalesce(cv.rate_norepinephrine, mv.rate_norepinephrine) as rate_norepinephrine
  , coalesce(cv.rate_epinephrine, mv.rate_epinephrine) as rate_epinephrine
  , coalesce(cv.rate_dopamine, mv.rate_dopamine) as rate_dopamine
  , coalesce(cv.rate_dobutamine, mv.rate_dobutamine) as rate_dobutamine

  , Creatinine_Max
  , Bilirubin_Max
  , Platelet_Min

  , pf.PaO2FiO2_novent_min
  , pf.PaO2FiO2_vent_min

  , uo.UrineOutput

  , gcs.MinGCS 
from icu_intervals ie
left join vaso_cv cv
  on ie.icustay_id = cv.icustay_id and ie.dailyInterval = cv.dailyInterval
left join vaso_mv mv
  on ie.icustay_id = mv.icustay_id and ie.dailyInterval = mv.dailyInterval
left join pafi2 pf
 on ie.icustay_id = pf.icustay_id and ie.dailyInterval = pf.dailyInterval
left join a_vitals v
  on ie.icustay_id = v.icustay_id and ie.dailyInterval = v.dailyInterval
left join a_labs l
  on ie.icustay_id = l.icustay_id and ie.dailyInterval = l.dailyInterval
left join a_uo uo
  on ie.icustay_id = uo.icustay_id and ie.dailyInterval = uo.dailyInterval
left join a_gcs gcs
  on ie.icustay_id = gcs.icustay_id and ie.dailyInterval = gcs.dailyInterval
)
, scorecalc as
(
  -- Calculate the final score
  -- note that if the underlying data is missing, the component is null
  -- eventually these are treated as 0 (normal), but knowing when data is missing is useful for debugging
  select icustay_id, dailyInterval
  -- Respiration
  , case
      when PaO2FiO2_vent_min   < 100 then 4
      when PaO2FiO2_vent_min   < 200 then 3
      when PaO2FiO2_novent_min < 300 then 2
      when PaO2FiO2_novent_min < 400 then 1
      when coalesce(PaO2FiO2_vent_min, PaO2FiO2_novent_min) is null then null
      else 0
    end as respiration

  -- Coagulation
  , case
      when platelet_min < 20  then 4
      when platelet_min < 50  then 3
      when platelet_min < 100 then 2
      when platelet_min < 150 then 1
      when platelet_min is null then null
      else 0
    end as coagulation

  -- Liver
  , case
      -- Bilirubin checks in mg/dL
        when Bilirubin_Max >= 12.0 then 4
        when Bilirubin_Max >= 6.0  then 3
        when Bilirubin_Max >= 2.0  then 2
        when Bilirubin_Max >= 1.2  then 1
        when Bilirubin_Max is null then null
        else 0
      end as liver

  -- Cardiovascular
  , case
      when rate_dopamine > 15 or rate_epinephrine >  0.1 or rate_norepinephrine >  0.1 then 4
      when rate_dopamine >  5 or rate_epinephrine <= 0.1 or rate_norepinephrine <= 0.1 then 3
      when rate_dopamine >  0 or rate_dobutamine > 0 then 2
      when MeanBP_Min < 70 then 1
      when coalesce(MeanBP_Min, rate_dopamine, rate_dobutamine, rate_epinephrine, rate_norepinephrine) is null then null
      else 0
    end as cardiovascular

  -- Neurological failure (GCS)
  , case
      when (MinGCS >= 13 and MinGCS <= 14) then 1
      when (MinGCS >= 10 and MinGCS <= 12) then 2
      when (MinGCS >=  6 and MinGCS <=  9) then 3
      when  MinGCS <   6 then 4
      when  MinGCS is null then null
  else 0 end
    as cns

  -- Renal failure - high creatinine or low urine output
  , case
    when (Creatinine_Max >= 5.0) then 4
    when  UrineOutput < 200 then 4
    when (Creatinine_Max >= 3.5 and Creatinine_Max < 5.0) then 3
    when  UrineOutput < 500 then 3
    when (Creatinine_Max >= 2.0 and Creatinine_Max < 3.5) then 2
    when (Creatinine_Max >= 1.2 and Creatinine_Max < 2.0) then 1
    when coalesce(UrineOutput, Creatinine_Max) is null then null
  else 0 end
    as renal
  from scorecomp
)
select ie.subject_id, ie.hadm_id, ie.icustay_id, dailyInterval AS dailyInterval
  -- Combine all the scores to get SOFA
  -- Impute 0 if the score is missing
  , coalesce(respiration,0)
  + coalesce(coagulation,0)
  + coalesce(liver,0)
  + coalesce(cardiovascular,0)
  + coalesce(cns,0)
  + coalesce(renal,0)
  as SOFA
, respiration
, coagulation
, liver
, cardiovascular
, cns
, renal
from icustays ie
left join scorecalc s
  on ie.icustay_id = s.icustay_id
order by ie.icustay_id, dailyInterval;

