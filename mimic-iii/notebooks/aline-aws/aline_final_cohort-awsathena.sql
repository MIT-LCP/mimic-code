CREATE TABLE DATABASE.ALINE_COHORT AS
select
  co.*
from DATABASE.ALINE_COHORT_ALL co
where exclusion_readmission = 0 -- first ICU stay
and exclusion_shortstay = 0 -- one day in the ICU
and exclusion_vasopressors = 0
and exclusion_septic = 0
and exclusion_aline_before_admission = 0 -- aline placed later than admission
-- and exclusion_aline_before_vent = 0
and exclusion_not_ventilated_first24hr = 0 -- were ventilated within first 24 hours
and exclusion_service_surgical = 0;