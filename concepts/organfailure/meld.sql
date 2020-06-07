-- Model for end-stage liver disease (MELD)
-- This model is used to determine prognosis and receipt of liver transplantation.

-- Reference:
--  Kamath PS, Wiesner RH, Malinchoc M, Kremers W, Therneau TM,
--  Kosberg CL, D'Amico G, Dickson ER, Kim WR.
--  A model to predict survival in patients with end-stage liver disease.
--  Hepatology. 2001 Feb;33(2):464-70.


-- Updated January 2016 to include serum sodium, see:
--  https://optn.transplant.hrsa.gov/news/meld-serum-sodium-policy-changes/

-- Here is the relevant portion of the policy note:
--    9.1.D MELD Score
--    Candidates who are at least 12 years old receive an initial MELD(i) score equal to:
--    0.957 x ln(creatinine mg/dL) + 0.378 x ln(bilirubin mg/dL) + 1.120 x ln(INR) + 0.643

--    Laboratory values less than 1.0 will be set to 1.0 when calculating a candidate’s MELD
--    score.

--    The following candidates will receive a creatinine value of 4.0 mg/dL:
--    - Candidates with a creatinine value greater than 4.0 mg/dL
--    - Candidates who received two or more dialysis treatments within the prior week
--    - Candidates who received 24 hours of continuous veno-venous hemodialysis (CVVHD) within the prior week

--    The maximum MELD score is 40. The MELD score derived from this calculation will be rounded to the tenth decimal place and then multiplied by 10.

--    For candidates with an initial MELD score greater than 11, The MELD score is then recalculated as follows:
--    MELD = MELD(i) + 1.32*(137-Na) – [0.033*MELD(i)*(137-Na)]
--    Sodium values less than 125 mmol/L will be set to 125, and values greater than 137 mmol/L will be set to 137.



-- TODO needed in this code:
--  1. identify 2x dialysis in the past week, or 24 hours of CVVH
--      at the moment it just checks for any dialysis on the day
--  2. adjust the serum sodium using the corresponding glucose measurement
--      Measured sodium + 0.024 * (Serum glucose - 100)   (Hiller, 1999)

CREATE VIEW `physionet-data.mimiciii_clinical.meld` AS
with cohort as
(
select ie.subject_id, ie.hadm_id, ie.icustay_id
      , ie.intime
      , ie.outtime

      , labs.creatinine_max
      , labs.bilirubin_max
      , labs.inr_max
      , labs.sodium_min

      , r.rrt

FROM `physionet-data.mimiciii_clinical.icustays` ie
inner join `physionet-data.mimiciii_clinical.admissions` adm
  on ie.hadm_id = adm.hadm_id
inner join `physionet-data.mimiciii_clinical.patients` pat
  on ie.subject_id = pat.subject_id

-- join to custom tables to get more data....
left join `physionet-data.mimiciii_clinical.labsfirstday` labs
  on ie.icustay_id = labs.icustay_id
left join `physionet-data.mimiciii_clinical.rrtfirstday` r
  on ie.icustay_id = r.icustay_id
)
, score as
(
  select subject_id, hadm_id, icustay_id
    , rrt
    , creatinine_max
    , bilirubin_max
    , inr_max
    , sodium_min

    -- TODO: Corrected Sodium
    , case
        when sodium_min is null
          then 0.0
        when sodium_min > 137
          then 0.0
        when sodium_min < 125
          then 12.0 -- 137 - 125 = 12
        else 137.0-sodium_min
      end as sodium_score

    -- if hemodialysis, value for Creatinine is automatically set to 4.0
    , case
        when rrt = 1 or creatinine_max > 4.0
          then (0.957 * ln(4))
        -- if creatinine < 1, score is 1
        when creatinine_max < 1
          then (0.957 * ln(1))
        else 0.957 * coalesce(ln(creatinine_max),ln(1))
      end as creatinine_score

    , case
        -- if value < 1, score is 1
        when bilirubin_max < 1
          then 0.378 * ln(1)
        else 0.378 * coalesce(ln(bilirubin_max),ln(1))
      end as bilirubin_score

    , case
        when inr_max < 1
          then ( 1.120 * ln(1) + 0.643 )
        else ( 1.120 * coalesce(ln(inr_max),ln(1)) + 0.643 )
      end as inr_score

  from cohort
)
, score2 as
(
  select
    subject_id, hadm_id, icustay_id
    , rrt
    , creatinine_max
    , bilirubin_max
    , inr_max
    , sodium_min

    , creatinine_score
    , sodium_score
    , bilirubin_score
    , inr_score

    , case
        when (creatinine_score + bilirubin_score + inr_score) > 40
          then 40.0
        else
          round(cast(creatinine_score + bilirubin_score + inr_score as numeric),1)*10
        end as meld_initial
  from score
)
select
  subject_id, hadm_id, icustay_id

  -- MELD Score without sodium change
  , meld_initial

  -- MELD Score (2016) = MELD*10 + 1.32*(137-Na) – [0.033*MELD*10*(137-Na)]
  , case
      when meld_initial > 11
        then meld_initial + 1.32*sodium_score - 0.033*meld_initial*sodium_score
      else
        meld_initial
      end as meld

  -- original variables
  , rrt
  , creatinine_max
  , bilirubin_max
  , inr_max
  , sodium_min

from score2
order by icustay_id;
