-- received colloid before admission
-- 226365  --  OR Colloid Intake
-- 226376  --  PACU Colloid Intake

with t1 as
(
  select
    mv.icustay_id
  , mv.starttime as charttime
  -- standardize the units to millilitres
  -- also metavision has floating point precision.. but we only care down to the mL
  , round(case
      when mv.amountuom = 'L'
        then mv.amount * 1000.0
      when mv.amountuom = 'ml'
        then mv.amount
    else null end) as amount
  from `physionet-data.mimiciii_clinical.inputevents_mv` mv
  where mv.itemid in
  (
    220864, --	Albumin 5%	7466 132 7466
    220862, --	Albumin 25%	9851 174 9851
    225174, --	Hetastarch (Hespan) 6%	82 1 82
    225795, --	Dextran 40	38 3 38
    225796  --  Dextran 70
    -- below ITEMIDs not in use
   -- 220861 | Albumin (Human) 20%
   -- 220863 | Albumin (Human) 4%
  )
  and mv.statusdescription != 'Rewritten'
  and
  -- in MetaVision, these ITEMIDs never appear with a null rate
  -- so it is sufficient to check the rate is > 100
    (
      (mv.rateuom = 'mL/hour' and mv.rate > 100)
      OR (mv.rateuom = 'mL/min' and mv.rate > (100/60.0))
      OR (mv.rateuom = 'mL/kg/hour' and (mv.rate*mv.patientweight) > 100)
    )
)
, t2 as
(
  select
    cv.icustay_id
  , cv.charttime
  -- carevue always has units in millilitres (or null)
  , round(cv.amount) as amount
  from `physionet-data.mimiciii_clinical.inputevents_cv` cv
  where cv.itemid in
  (
   30008 --	Albumin 5%
  ,30009 --	Albumin 25%
  ,42832 --	albumin 12.5%
  ,40548 --	ALBUMIN
  ,45403 --	albumin
  ,44203 --	Albumin 12.5%
  ,30181 -- Serum Albumin 5%
  ,46564 -- Albumin
  ,43237 -- 25% Albumin
  ,43353 -- Albumin (human) 25%

  ,30012 --	Hespan
  ,46313 --	6% Hespan

  ,30011 -- Dextran 40
  ,30016 -- Dextrose 10%
  ,42975 --	DEXTRAN DRIP
  ,42944 --	dextran
  ,46336 --	10% Dextran 40/D5W
  ,46729 --	Dextran
  ,40033 --	DEXTRAN
  ,45410 --	10% Dextran 40
  ,42731 -- Dextran40 10%
  )
  and cv.amount > 100
  and cv.amount < 2000
)
-- some colloids are charted in chartevents
, t3 as
(
  select
    ce.icustay_id
  , ce.charttime
  -- carevue always has units in millilitres (or null)
  , round(ce.valuenum) as amount
  from `physionet-data.mimiciii_clinical.chartevents` ce
  where ce.itemid in
  (
      2510 --	DEXTRAN LML 10%
    , 3087 --	DEXTRAN 40  10%
    , 6937 --	Dextran
    , 3087 -- DEXTRAN 40  10%
    , 3088 --	DEXTRAN 40%
  )
  and ce.valuenum is not null
  and ce.valuenum > 100
  and ce.valuenum < 2000
)
select
    icustay_id
  , charttime
  , sum(amount) as colloid_bolus
from t1
-- just because the rate was high enough, does *not* mean the final amount was
where amount > 100
group by t1.icustay_id, t1.charttime
UNION ALL
select
    icustay_id
  , charttime
  , sum(amount) as colloid_bolus
from t2
group by t2.icustay_id, t2.charttime
UNION ALL 
select
    icustay_id
  , charttime
  , sum(amount) as colloid_bolus
from t3
group by t3.icustay_id, t3.charttime
order by icustay_id, charttime;

