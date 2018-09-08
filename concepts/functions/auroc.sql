-- Calculate the AUROC of age for predicting in-hospital mortality
-- You can easily calculate the AUROC of any model you'd like by:
--  Replacing "PRED" with your predictor
--  Replacing "TAR" with the target (*must* be a binary target)

with datatable as (
select
  -- name the predictor "PRED"
  cast(adm.admittime as date) - cast(pat.dob as date) as PRED -- age is our predictor
  -- name the target variable "TAR"
  , case when adm.deathtime is not null then 1 else 0 end as TAR -- in-hospital mortality
FROM `physionet-data.mimiciii_clinical.admissions` adm
inner join patients pat
  on adm.subject_id = pat.subject_id
)
, datacs as (
select
  TAR
  -- calculate the cumulative sum of negative targets, then multiply by positive targets
  -- this has the effect of returning 0 for negative targets, and the # of negative targets below each positive target
  , TAR * SUM(1-TAR) OVER (ORDER BY PRED ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS AUROC
from datatable
)
select
  -- Calculate the AUROC as:
  --    SUM( number of negative targets below each positive target )
  -- /  number of possible negative/positive target pairs
  round(sum(AUROC) / (sum(TAR)*sum(1-TAR)),4) as AUROC
from datacs;
