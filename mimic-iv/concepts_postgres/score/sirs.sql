-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS sirs; CREATE TABLE sirs AS 
-- ------------------------------------------------------------------
-- Title: Systemic inflammatory response syndrome (SIRS) criteria
-- This query extracts the Systemic inflammatory response syndrome (SIRS) criteria
-- The criteria quantify the level of inflammatory response of the body
-- The score is calculated on the first day of each ICU patients' stay.
-- ------------------------------------------------------------------

-- Reference for SIRS:
--    American College of Chest Physicians/Society of Critical Care Medicine Consensus Conference:
--    definitions for sepsis and organ failure and guidelines for the use of innovative therapies in sepsis"
--    Crit. Care Med. 20 (6): 864–74. 1992.
--    doi:10.1097/00003246-199206000-00025. PMID 1597042.

-- Variables used in SIRS:
--  Body temperature (min and max)
--  Heart rate (max)
--  Respiratory rate (max)
--  PaCO2 (min)
--  White blood cell count (min and max)
--  the presence of greater than 10% immature neutrophils (band forms)

-- Note:
--  The score is calculated for *all* ICU patients, with the assumption that the user will subselect appropriate stay_ids.
--  For example, the score is calculated for neonates, but it is likely inappropriate to actually use the score values for these patients.

-- Aggregate the components for the score
with scorecomp as
(
select ie.stay_id
  , v.temperature_min
  , v.temperature_max
  , v.heart_rate_max
  , v.resp_rate_max
  , bg.pco2_min AS paco2_min
  , l.wbc_min
  , l.wbc_max
  , l.bands_max
FROM mimiciv_icu.icustays ie
left join mimiciv_derived.first_day_bg_art bg
 on ie.stay_id = bg.stay_id
left join mimiciv_derived.first_day_vitalsign v
  on ie.stay_id = v.stay_id
left join mimiciv_derived.first_day_lab l
  on ie.stay_id = l.stay_id
)
, scorecalc as
(
  -- Calculate the final score
  -- note that if the underlying data is missing, the component is null
  -- eventually these are treated as 0 (normal), but knowing when data is missing is useful for debugging
  select stay_id

  , case
      when temperature_min < 36.0 then 1
      when temperature_max > 38.0 then 1
      when temperature_min is null then null
      else 0
    end as temp_score


  , case
      when heart_rate_max > 90.0  then 1
      when heart_rate_max is null then null
      else 0
    end as heart_rate_score

  , case
      when resp_rate_max > 20.0  then 1
      when paco2_min < 32.0  then 1
      when coalesce(resp_rate_max, paco2_min) is null then null
      else 0
    end as resp_score

  , case
      when wbc_min <  4.0  then 1
      when wbc_max > 12.0  then 1
      when bands_max > 10 then 1-- > 10% immature neurophils (band forms)
      when coalesce(wbc_min, bands_max) is null then null
      else 0
    end as wbc_score

  from scorecomp
)
select
  ie.subject_id, ie.hadm_id, ie.stay_id
  -- Combine all the scores to get SOFA
  -- Impute 0 if the score is missing
  , coalesce(temp_score,0)
  + coalesce(heart_rate_score,0)
  + coalesce(resp_score,0)
  + coalesce(wbc_score,0)
    as sirs
  , temp_score, heart_rate_score, resp_score, wbc_score
FROM mimiciv_icu.icustays ie
left join scorecalc s
  on ie.stay_id = s.stay_id
;
