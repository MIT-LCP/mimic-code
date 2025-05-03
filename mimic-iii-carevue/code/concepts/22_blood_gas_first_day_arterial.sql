drop table if exists blood_gas_first_day_arterial; create table blood_gas_first_day_arterial as 

with stg_spo2 as
(
  select subject_id, hadm_id, icustay_id, charttime
    -- max here is just used to group SpO2 by charttime
    , max(case when valuenum <= 0 or valuenum > 100 then null else valuenum end) as spo2
  from chartevents
  -- o2 sat
  where itemid in (646) -- SpO2
  group by subject_id, hadm_id, icustay_id, charttime
)
, stg_fio2 as
(
  select subject_id, hadm_id, icustay_id, charttime
    -- pre-process the FiO2s to ensure they are between 21-100%
    , max(
      case
        when itemid in (3420, 3422)
        -- all these values are well formatted
            then valuenum
        when itemid = 190 and valuenum > 0.20 and valuenum < 1
        -- well formatted but not in %
            then valuenum * 100
      else null end
    ) as fio2_chartevents
  from chartevents
  where itemid in
  (
    3420 -- FiO2
  , 190 -- FiO2 set
  , 3422 -- FiO2 [measured]
  )
  -- exclude rows marked as error
  and (error is null or error = 0)
  group by subject_id, hadm_id, icustay_id, charttime
)
, stg2 as
(
select bg.*
  , row_number() over (partition by bg.icustay_id, bg.charttime order by s1.charttime desc) as lastrowspo2
  , s1.spo2
from blood_gas_first_day bg
left join stg_spo2 s1
  -- same patient
  on  bg.icustay_id = s1.icustay_id
  -- spo2 occurred at most 2 hours before this blood gas
  and s1.charttime >= (bg.charttime - interval '2 hour')
  and s1.charttime <= bg.charttime
where bg.po2 is not null
)
, stg3 as
(
select bg.*
  , row_number() over (partition by bg.icustay_id, bg.charttime order by s2.charttime desc) as lastrowfio2
  , s2.fio2_chartevents

  -- create our specimen prediction
  ,  1/(1+exp(-(-0.02544
  +    0.04598 * po2
  + coalesce(-0.15356 * spo2             , -0.15356 *   97.49420 +    0.13429)
  + coalesce( 0.00621 * fio2_chartevents ,  0.00621 *   51.49550 +   -0.24958)
  + coalesce( 0.10559 * hemoglobin       ,  0.10559 *   10.32307 +    0.05954)
  + coalesce( 0.13251 * so2              ,  0.13251 *   93.66539 +   -0.23172)
  + coalesce(-0.01511 * pco2             , -0.01511 *   42.08866 +   -0.01630)
  + coalesce( 0.01480 * fio2             ,  0.01480 *   63.97836 +   -0.31142)
  + coalesce(-0.00200 * aado2            , -0.00200 *  442.21186 +   -0.01328)
  + coalesce(-0.03220 * bicarbonate      , -0.03220 *   22.96894 +   -0.06535)
  + coalesce( 0.05384 * totalco2         ,  0.05384 *   24.72632 +   -0.01405)
  + coalesce( 0.08202 * lactate          ,  0.08202 *    3.06436 +    0.06038)
  + coalesce( 0.10956 * ph               ,  0.10956 *    7.36233 +   -0.00617)
  + coalesce( 0.00848 * o2flow           ,  0.00848 *    7.59362 +   -0.35803)
  ))) as specimen_prob
from stg2 bg
left join stg_fio2 s2
  -- same patient
  on  bg.icustay_id = s2.icustay_id
  -- fio2 occurred at most 4 hours before this blood gas
  and s2.charttime between (bg.charttime - interval '4 hour') and bg.charttime
where bg.lastrowspo2 = 1 -- only the row with the most recent SpO2 (if no SpO2 found lastRowSpO2 = 1)
)

select subject_id, hadm_id,
icustay_id, charttime
, specimen -- raw data indicating sample type, only present 80% of the time

-- prediction of specimen for missing data
, case
      when specimen is not null then specimen
      when specimen_prob > 0.75 then 'ART'
    else null end as specimen_pred
, specimen_prob

-- oxygen related parameters
, so2, spo2 -- note spo2 is from chartevents
, po2, pco2
, fio2_chartevents, fio2
, aado2
-- also calculate AADO2
, case
    when  PO2 is not null
      and pco2 is not null
      and coalesce(fio2, fio2_chartevents) is not null
     -- multiple by 100 because FiO2 is in a % but should be a fraction
      then (coalesce(fio2, fio2_chartevents)/100) * (760 - 47) - (pco2/0.8) - po2
    else null
  end as aado2_calc
, case
    when po2 is not null and coalesce(fio2, fio2_chartevents) is not null
     -- multiply by 100 because FiO2 is in a % but should be a fraction
      then 100*po2/(coalesce(fio2, fio2_chartevents))
    else null
  end as pao2fio2
-- acid-base parameters
, ph, baseexcess
, bicarbonate, totalco2

-- blood count parameters
, hematocrit
, hemoglobin
, carboxyhemoglobin
, methemoglobin

-- chemistry
, chloride, calcium
, temperature
, potassium, sodium
, lactate
, glucose

-- ventilation stuff that's sometimes input
, intubated, tidalvolume, ventilationrate, ventilator
, peep, o2flow
, requiredo2

from stg3
where lastrowfio2 = 1 -- only the most recent FiO2
-- restrict it to *only* arterial samples
and (specimen = 'ART' or specimen_prob > 0.75)
order by icustay_id, charttime;
