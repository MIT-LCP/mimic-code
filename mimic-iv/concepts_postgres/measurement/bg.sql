-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS bg; CREATE TABLE bg AS 
-- The aim of this query is to pivot entries related to blood gases
-- which were found in LABEVENTS
WITH bg AS
(
select
  -- specimen_id only ever has 1 measurement for each itemid
  -- so, we may simply collapse rows using MAX()
    MAX(subject_id) AS subject_id
  , MAX(hadm_id) AS hadm_id
  , MAX(charttime) AS charttime
  -- specimen_id *may* have different storetimes, so this is taking the latest
  , MAX(storetime) AS storetime
  , le.specimen_id
  , MAX(CASE WHEN itemid = 52033 THEN value ELSE NULL END) AS specimen
  , MAX(CASE WHEN itemid = 50801 THEN valuenum ELSE NULL END) AS aado2
  , MAX(CASE WHEN itemid = 50802 THEN valuenum ELSE NULL END) AS baseexcess
  , MAX(CASE WHEN itemid = 50803 THEN valuenum ELSE NULL END) AS bicarbonate
  , MAX(CASE WHEN itemid = 50804 THEN valuenum ELSE NULL END) AS totalco2
  , MAX(CASE WHEN itemid = 50805 THEN valuenum ELSE NULL END) AS carboxyhemoglobin
  , MAX(CASE WHEN itemid = 50806 THEN valuenum ELSE NULL END) AS chloride
  , MAX(CASE WHEN itemid = 50808 THEN valuenum ELSE NULL END) AS calcium
  , MAX(CASE WHEN itemid = 50809 and valuenum <= 10000 THEN valuenum ELSE NULL END) AS glucose
  , MAX(CASE WHEN itemid = 50810 and valuenum <= 100 THEN valuenum ELSE NULL END) AS hematocrit
  , MAX(CASE WHEN itemid = 50811 THEN valuenum ELSE NULL END) AS hemoglobin
  , MAX(CASE WHEN itemid = 50813 and valuenum <= 10000 THEN valuenum ELSE NULL END) AS lactate
  , MAX(CASE WHEN itemid = 50814 THEN valuenum ELSE NULL END) AS methemoglobin
  , MAX(CASE WHEN itemid = 50815 THEN valuenum ELSE NULL END) AS o2flow
  -- fix a common unit conversion error for fio2
  -- atmospheric o2 is 20.89%, so any value <= 20 is unphysiologic
  -- usually this is a misplaced O2 flow measurement
  , MAX(CASE WHEN itemid = 50816 THEN
      CASE
        WHEN valuenum > 20 AND valuenum <= 100 THEN valuenum
        WHEN valuenum > 0.2 AND valuenum <= 1.0 THEN valuenum*100.0
      ELSE NULL END
    ELSE NULL END) AS fio2
  , MAX(CASE WHEN itemid = 50817 AND valuenum <= 100 THEN valuenum ELSE NULL END) AS so2
  , MAX(CASE WHEN itemid = 50818 THEN valuenum ELSE NULL END) AS pco2
  , MAX(CASE WHEN itemid = 50819 THEN valuenum ELSE NULL END) AS peep
  , MAX(CASE WHEN itemid = 50820 THEN valuenum ELSE NULL END) AS ph
  , MAX(CASE WHEN itemid = 50821 THEN valuenum ELSE NULL END) AS po2
  , MAX(CASE WHEN itemid = 50822 THEN valuenum ELSE NULL END) AS potassium
  , MAX(CASE WHEN itemid = 50823 THEN valuenum ELSE NULL END) AS requiredo2
  , MAX(CASE WHEN itemid = 50824 THEN valuenum ELSE NULL END) AS sodium
  , MAX(CASE WHEN itemid = 50825 THEN valuenum ELSE NULL END) AS temperature
  , MAX(CASE WHEN itemid = 50807 THEN value ELSE NULL END) AS comments
FROM mimiciv_hosp.labevents le
where le.ITEMID in
-- blood gases
(
    52033 -- specimen
  , 50801 -- aado2
  , 50802 -- base excess
  , 50803 -- bicarb
  , 50804 -- calc tot co2
  , 50805 -- carboxyhgb
  , 50806 -- chloride
  -- , 52390 -- chloride, WB CL-
  , 50807 -- comments
  , 50808 -- free calcium
  , 50809 -- glucose
  , 50810 -- hct
  , 50811 -- hgb
  , 50813 -- lactate
  , 50814 -- methemoglobin
  , 50815 -- o2 flow
  , 50816 -- fio2
  , 50817 -- o2 sat
  , 50818 -- pco2
  , 50819 -- peep
  , 50820 -- pH
  , 50821 -- pO2
  , 50822 -- potassium
  -- , 52408 -- potassium, WB K+
  , 50823 -- required O2
  , 50824 -- sodium
  -- , 52411 -- sodium, WB NA +
  , 50825 -- temperature
)
GROUP BY le.specimen_id
)
, stg_spo2 as
(
  select subject_id, charttime
    -- avg here is just used to group SpO2 by charttime
    , AVG(valuenum) as SpO2
  FROM mimiciv_icu.chartevents
  where ITEMID = 220277 -- O2 saturation pulseoxymetry
  and valuenum > 0 and valuenum <= 100
  group by subject_id, charttime
)
, stg_fio2 as
(
  select subject_id, charttime
    -- pre-process the FiO2s to ensure they are between 21-100%
    , max(
        case
          when valuenum > 0.2 and valuenum <= 1
            then valuenum * 100
          -- improperly input data - looks like O2 flow in litres
          when valuenum > 1 and valuenum < 20
            then null
          when valuenum >= 20 and valuenum <= 100
            then valuenum
      else null end
    ) as fio2_chartevents
  FROM mimiciv_icu.chartevents
  where ITEMID = 223835 -- Inspired O2 Fraction (FiO2)
  and valuenum > 0 and valuenum <= 100
  group by subject_id, charttime
)
, stg2 as
(
select bg.*
  , ROW_NUMBER() OVER (partition by bg.subject_id, bg.charttime order by s1.charttime DESC) as lastRowSpO2
  , s1.spo2
from bg
left join stg_spo2 s1
  -- same hospitalization
  on  bg.subject_id = s1.subject_id
  -- spo2 occurred at most 2 hours before this blood gas
  and s1.charttime between DATETIME_SUB(bg.charttime, INTERVAL '2' HOUR) and bg.charttime
where bg.po2 is not null
)
, stg3 as
(
select bg.*
  , ROW_NUMBER() OVER (partition by bg.subject_id, bg.charttime order by s2.charttime DESC) as lastRowFiO2
  , s2.fio2_chartevents
from stg2 bg
left join stg_fio2 s2
  -- same patient
  on  bg.subject_id = s2.subject_id
  -- fio2 occurred at most 4 hours before this blood gas
  and s2.charttime between DATETIME_SUB(bg.charttime, INTERVAL '4' HOUR) and bg.charttime
  AND s2.fio2_chartevents > 0
where bg.lastRowSpO2 = 1 -- only the row with the most recent SpO2 (if no SpO2 found lastRowSpO2 = 1)
)
select
    stg3.subject_id
  , stg3.hadm_id
  , stg3.charttime
  -- drop down text indicating the specimen type
  , specimen

  -- oxygen related parameters
  , so2
  , po2
  , pco2
  , fio2_chartevents, fio2
  , aado2
  -- also calculate AADO2
  , case
      when  po2 is null
        OR pco2 is null
      THEN NULL
      WHEN fio2 IS NOT NULL
        -- multiple by 100 because fio2 is in a % but should be a fraction
        THEN (fio2/100) * (760 - 47) - (pco2/0.8) - po2
      WHEN fio2_chartevents IS NOT NULL
        THEN (fio2_chartevents/100) * (760 - 47) - (pco2/0.8) - po2
      else null
    end as aado2_calc
  , case
      when PO2 is null
        THEN NULL
      WHEN fio2 IS NOT NULL
       -- multiply by 100 because fio2 is in a % but should be a fraction
        then 100 * PO2/fio2
      WHEN fio2_chartevents IS NOT NULL
       -- multiply by 100 because fio2 is in a % but should be a fraction
        then 100 * PO2/fio2_chartevents
      else null
    end as pao2fio2ratio
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
  -- , intubated, tidalvolume, ventilationrate, ventilator
  -- , peep, o2flow
  -- , requiredo2
from stg3
where lastRowFiO2 = 1 -- only the most recent FiO2
;
