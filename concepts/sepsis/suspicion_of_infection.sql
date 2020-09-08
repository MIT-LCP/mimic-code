with abx as
(
  select stay_id
    , suspected_infection_time
    , specimen, positiveculture
    , antibiotic_name
    , antibiotic_time
    , ROW_NUMBER() OVER
    (
      PARTITION BY stay_id
      ORDER BY suspected_infection_time
    ) as rn
  from `physionet-data.mimic_derived.abx_micro_poe`
)
select
  ie.stay_id
  , antibiotic_name
  , antibiotic_time
  , suspected_infection_time
  , specimen, positiveculture
from `physionet-data.mimic_icu.icustays` ie
left join abx
  on ie.stay_id = abx.stay_id
  and abx.rn = 1
;
