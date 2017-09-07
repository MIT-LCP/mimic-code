-- The aim of this query is to pivot entries related to blood gases and
-- chemistry values which were found in LABEVENTS

-- things to check:
--  when a mixed venous/arterial blood sample are taken at the same time, is the store time different?

DROP MATERIALIZED VIEW IF EXISTS bloodgasfirstday CASCADE;
create materialized view bloodgasfirstday as
with pvt as
( -- begin query that extracts the data
  select ie.subject_id, ie.hadm_id, ie.icustay_id
  -- here we assign labels to ITEMIDs
  -- this also fuses together multiple ITEMIDs containing the same data
      , case
        when itemid = 50800 then 'SPECIMEN'
        when itemid = 50801 then 'AADO2'
        when itemid = 50802 then 'BASEEXCESS'
        when itemid = 50803 then 'BICARBONATE'
        when itemid = 50804 then 'TOTALCO2'
        when itemid = 50805 then 'CARBOXYHEMOGLOBIN'
        when itemid = 50806 then 'CHLORIDE'
        when itemid = 50808 then 'CALCIUM'
        when itemid = 50809 then 'GLUCOSE'
        when itemid = 50810 then 'HEMATOCRIT'
        when itemid = 50811 then 'HEMOGLOBIN'
        when itemid = 50812 then 'INTUBATED'
        when itemid = 50813 then 'LACTATE'
        when itemid = 50814 then 'METHEMOGLOBIN'
        when itemid = 50815 then 'O2FLOW'
        when itemid = 50816 then 'FIO2'
        when itemid = 50817 then 'SO2' -- OXYGENSATURATION
        when itemid = 50818 then 'PCO2'
        when itemid = 50819 then 'PEEP'
        when itemid = 50820 then 'PH'
        when itemid = 50821 then 'PO2'
        when itemid = 50822 then 'POTASSIUM'
        when itemid = 50823 then 'REQUIREDO2'
        when itemid = 50824 then 'SODIUM'
        when itemid = 50825 then 'TEMPERATURE'
        when itemid = 50826 then 'TIDALVOLUME'
        when itemid = 50827 then 'VENTILATIONRATE'
        when itemid = 50828 then 'VENTILATOR'
        else null
        end as label
        , charttime
        , value
        -- add in some sanity checks on the values
        , case
          when valuenum <= 0 then null
          when itemid = 50810 and valuenum > 100 then null -- hematocrit
          -- ensure FiO2 is a valid number between 21-100
          -- mistakes are rare (<100 obs out of ~100,000)
          -- there are 862 obs of valuenum == 20 - some people round down!
          -- rather than risk imputing garbage data for FiO2, we simply NULL invalid values
          when itemid = 50816 and valuenum < 20 then null
          when itemid = 50816 and valuenum > 100 then null
          when itemid = 50817 and valuenum > 100 then null -- O2 sat
          when itemid = 50815 and valuenum >  70 then null -- O2 flow
          when itemid = 50821 and valuenum > 800 then null -- PO2
           -- conservative upper limit
        else valuenum
        end as valuenum

    from icustays ie
    left join labevents le
      on le.subject_id = ie.subject_id and le.hadm_id = ie.hadm_id
      and le.charttime between (ie.intime - interval '6' hour) and (ie.intime + interval '1' day)
      and le.ITEMID in
      -- blood gases
      (
        50800, 50801, 50802, 50803, 50804, 50805, 50806, 50807, 50808, 50809
        , 50810, 50811, 50812, 50813, 50814, 50815, 50816, 50817, 50818, 50819
        , 50820, 50821, 50822, 50823, 50824, 50825, 50826, 50827, 50828
        , 51545
      )
)
select pvt.SUBJECT_ID, pvt.HADM_ID, pvt.ICUSTAY_ID, pvt.CHARTTIME
, max(case when label = 'SPECIMEN' then value else null end) as SPECIMEN
, max(case when label = 'AADO2' then valuenum else null end) as AADO2
, max(case when label = 'BASEEXCESS' then valuenum else null end) as BASEEXCESS
, max(case when label = 'BICARBONATE' then valuenum else null end) as BICARBONATE
, max(case when label = 'TOTALCO2' then valuenum else null end) as TOTALCO2
, max(case when label = 'CARBOXYHEMOGLOBIN' then valuenum else null end) as CARBOXYHEMOGLOBIN
, max(case when label = 'CHLORIDE' then valuenum else null end) as CHLORIDE
, max(case when label = 'CALCIUM' then valuenum else null end) as CALCIUM
, max(case when label = 'GLUCOSE' then valuenum else null end) as GLUCOSE
, max(case when label = 'HEMATOCRIT' then valuenum else null end) as HEMATOCRIT
, max(case when label = 'HEMOGLOBIN' then valuenum else null end) as HEMOGLOBIN
, max(case when label = 'INTUBATED' then valuenum else null end) as INTUBATED
, max(case when label = 'LACTATE' then valuenum else null end) as LACTATE
, max(case when label = 'METHEMOGLOBIN' then valuenum else null end) as METHEMOGLOBIN
, max(case when label = 'O2FLOW' then valuenum else null end) as O2FLOW
, max(case when label = 'FIO2' then valuenum else null end) as FIO2
, max(case when label = 'SO2' then valuenum else null end) as SO2 -- OXYGENSATURATION
, max(case when label = 'PCO2' then valuenum else null end) as PCO2
, max(case when label = 'PEEP' then valuenum else null end) as PEEP
, max(case when label = 'PH' then valuenum else null end) as PH
, max(case when label = 'PO2' then valuenum else null end) as PO2
, max(case when label = 'POTASSIUM' then valuenum else null end) as POTASSIUM
, max(case when label = 'REQUIREDO2' then valuenum else null end) as REQUIREDO2
, max(case when label = 'SODIUM' then valuenum else null end) as SODIUM
, max(case when label = 'TEMPERATURE' then valuenum else null end) as TEMPERATURE
, max(case when label = 'TIDALVOLUME' then valuenum else null end) as TIDALVOLUME
, max(case when label = 'VENTILATIONRATE' then valuenum else null end) as VENTILATIONRATE
, max(case when label = 'VENTILATOR' then valuenum else null end) as VENTILATOR
from pvt
group by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.CHARTTIME
order by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, pvt.CHARTTIME;
