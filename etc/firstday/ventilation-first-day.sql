-- Determines if a patient is ventilated on the first day of their ICU stay.
-- Creates a table with the result.

CREATE MATERIALIZED VIEW ventfirstday AS
-- group together the flags based on icustay_id
select
  subject_id, hadm_id, icustay_id
  , max(case
      -- if no chart data matched, they are not ventilated
      when value is null
      then 0
      when (VentTypeRecorded + MinuteVolume + TV + InspPressure
        + PlateauPressure + APRVPressure + PEEP + HighPressureRelease
        + PCV + TCPCV + RespPressure + psvlevel + ett + O2FromVentilator) > 0
      then 1
      else 0
      end) as MechVent
from
(
select
  ie.subject_id, ie.icustay_id, ie.hadm_id, ce.charttime
  , ce.itemid, di.label, ce.value
  , case
      when ce.itemid = 720 and value != 'Other/Remarks' then 1
    else 0 end as VentTypeRecorded -- VentType

  , case
      when ce.itemid in (445, 448, 449, 450, 1340, 1486, 1600, 224687) then 1 -- minute volume
    else 0 end as MinuteVolume -- MinuteVolume

  , case
      when ce.itemid in (639, 654, 681, 682, 683, 684,224685,224684,224686) then 1 -- tidal volume
    else 0 end as TV -- TidalVolume

  , case
      when ce.itemid in (218,436,535,444,459,224697,224695,224696,224746,224747) then 1 -- High/Low/Peak/Mean/Neg insp force
    else 0 end as RespPressure
  , case
      when ce.itemid in (221,1,1211,1655,2000,226873,224738,224419,224750,227187) then 1 -- Insp pressure
    else 0 end as InspPressure

  , case
      when ce.itemid in (543) then 1 -- PlateauPressure
    else 0 end as PlateauPressure

  , case
      when ce.itemid in (5865,5866,224707,224709,224705,224706) then 1 -- APRV pressure
    else 0 end as APRVPressure

  , case
      when ce.itemid in (60,437,505,506,686,220339,224700) then 1 -- peep
    else 0 end as PEEP

  , case
      when ce.itemid in (141,224417,224418) then 1 -- cuff volume/pressure
    else 0 end as CuffPressure

  , case
      when ce.itemid in (3459) then 1 -- high pressure relief
    else 0 end as HighPressureRelease

  , case
      when ce.itemid in (501,502,503,224702) then 1 -- PCV
    else 0 end as PCV

  , case
      when ce.itemid in (223,667,668,669,670,671,672) then 1 -- TCPCV
    else 0 end as TCPCV -- TCPCV

  , case
      when ce.itemid = 467 and ce.value = 'Ventilator' then 1 -- O2 delivery device == ventilator
    else 0 end as O2FromVentilator

  , case
      when ce.itemid in (578,3605) then 1 -- Pressure/Respiratory
    else 0 end as PressureSupport -- Pressure/Respiratory

  , case
      when ce.itemid in (3688,3689) then 1 -- Vt [Ventilator] and Vt [Spontaneous] - measured in inches??? :S
    else 0 end as VtInches

  , case
      when ce.itemid in (63,64,65,66,67,68
        ,227579,227580,227582,227581) then 1 -- BIPAP
    else 0 end as BIPAP --

  , case
      when ce.itemid in (157,158,1852,3398,3399,3400,3401,3402,3403,3404,8382
          ,227809,227810) then 1 -- ETT
    else 0 end as ETT --

  , case
      when ce.itemid in (224701) then 1 else 0 end PSVlevel

  , case
      when ce.itemid in (223835) then 1 -- FiO2
    else 0 end as FiO2

  , case
      when ce.itemid in (614,615,619,653,224688,224690,224689) then 1
    else 0 end as RespRate -- RespRate
  , case
      when ce.itemid in (194, 195, 224691) then 1 -- flow by
    else 0 end as FlowBy

  , case
      when ce.itemid in (470,471,223834,227287) then 1 -- O2 FLOW
    else 0 end as O2Flow

  , case
      when ce.itemid = 648 and value = 'Intubated/trach' THEN 1 -- Speech = intubated
    else 0 end as SpeechIntubated

from icustays ie
left join chartevents ce
  on ie.icustay_id = ce.icustay_id and ce.value is not null
  -- only first day of their ICU stay
  and ce.charttime between ie.intime and ie.intime + interval '1' day
left join d_items di
  on ce.itemid = di.itemid
) AS tt
group by subject_id, hadm_id, icustay_id
order by subject_id, hadm_id, icustay_id;
