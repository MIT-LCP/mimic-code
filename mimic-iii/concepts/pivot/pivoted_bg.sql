-- The aim of this query is to pivot entries related to blood gases and
-- chemistry values which were found in LABEVENTS

-- create a table which has fuzzy boundaries on ICU admission
-- involves first creating a lag/lead version of intime/outtime
with i as
(
  select
    subject_id, icustay_id, intime, outtime
    , lag (outtime) over (partition by subject_id order by intime) as outtime_lag
    , lead (intime) over (partition by subject_id order by intime) as intime_lead
  FROM `physionet-data.mimiciii_clinical.icustays`
)
, iid_assign as
(
  select
    i.subject_id, i.icustay_id
    -- this rule is:
    --  if there are two hospitalizations within 24 hours, set the start/stop
    --  time as half way between the two admissions
    , case
        when i.outtime_lag is not null
        and i.outtime_lag > (DATETIME_SUB(i.intime, INTERVAL 24 HOUR))
          then DATETIME_SUB(i.intime, INTERVAL cast(round((DATETIME_DIFF(i.intime, i.outtime_lag, hour)/2)) as int64) HOUR)
      else DATETIME_SUB(i.intime, INTERVAL 12 HOUR)
      end as data_start
    , case
        when i.intime_lead is not null
        and i.intime_lead < (DATETIME_ADD(i.outtime, INTERVAL 24 HOUR))
          then DATETIME_ADD(i.outtime, INTERVAL cast(round((DATETIME_DIFF(i.intime_lead, i.outtime, minute)/2)) as int64) MINUTE)
      else (DATETIME_ADD(i.outtime, INTERVAL 12 HOUR))
      end as data_end
    from i
)
, pvt as
( -- begin query that extracts the data
  select le.hadm_id
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
    FROM `physionet-data.mimiciii_clinical.labevents` le
    where le.ITEMID in
    -- blood gases
    (
      50800, 50801, 50802, 50803, 50804, 50805, 50806, 50807, 50808, 50809
      , 50810, 50811, 50812, 50813, 50814, 50815, 50816, 50817, 50818, 50819
      , 50820, 50821, 50822, 50823, 50824, 50825, 50826, 50827, 50828
      , 51545
    )
)
, grp as
(
  select pvt.hadm_id, pvt.charttime
  , max(case when label = 'SPECIMEN' then value else null end) as specimen
  , avg(case when label = 'AADO2' then valuenum else null end) as aado2
  , avg(case when label = 'BASEEXCESS' then valuenum else null end) as baseexcess
  , avg(case when label = 'BICARBONATE' then valuenum else null end) as bicarbonate
  , avg(case when label = 'TOTALCO2' then valuenum else null end) as totalco2
  , avg(case when label = 'CARBOXYHEMOGLOBIN' then valuenum else null end) as carboxyhemoglobin
  , avg(case when label = 'CHLORIDE' then valuenum else null end) as chloride
  , avg(case when label = 'CALCIUM' then valuenum else null end) as calcium
  , avg(case when label = 'GLUCOSE' then valuenum else null end) as glucose
  , avg(case when label = 'HEMATOCRIT' then valuenum else null end) as hematocrit
  , avg(case when label = 'HEMOGLOBIN' then valuenum else null end) as hemoglobin
  , avg(case when label = 'INTUBATED' then valuenum else null end) as intubated
  , avg(case when label = 'LACTATE' then valuenum else null end) as lactate
  , avg(case when label = 'METHEMOGLOBIN' then valuenum else null end) as methemoglobin
  , avg(case when label = 'O2FLOW' then valuenum else null end) as o2flow
  , avg(case when label = 'FIO2' then valuenum else null end) as fio2
  , avg(case when label = 'SO2' then valuenum else null end) as so2 -- OXYGENSATURATION
  , avg(case when label = 'PCO2' then valuenum else null end) as pco2
  , avg(case when label = 'PEEP' then valuenum else null end) as peep
  , avg(case when label = 'PH' then valuenum else null end) as ph
  , avg(case when label = 'PO2' then valuenum else null end) as po2
  , avg(case when label = 'POTASSIUM' then valuenum else null end) as potassium
  , avg(case when label = 'REQUIREDO2' then valuenum else null end) as requiredo2
  , avg(case when label = 'SODIUM' then valuenum else null end) as sodium
  , avg(case when label = 'TEMPERATURE' then valuenum else null end) as temperature
  , avg(case when label = 'TIDALVOLUME' then valuenum else null end) as tidalvolume
  , max(case when label = 'VENTILATIONRATE' then valuenum else null end) as ventilationrate
  , max(case when label = 'VENTILATOR' then valuenum else null end) as ventilator
  from pvt
  group by pvt.hadm_id, pvt.charttime
  -- remove observations if there is more than one specimen listed
  -- we do not know whether these are arterial or mixed venous, etc...
  -- happily this is a small fraction of the total number of observations
  having sum(case when label = 'SPECIMEN' then 1 else 0 end)<2
)
select
  iid.icustay_id, grp.*
from grp
inner join `physionet-data.mimiciii_clinical.admissions` adm
  on grp.hadm_id = adm.hadm_id
left join iid_assign iid
  on adm.subject_id = iid.subject_id
  and grp.charttime >= iid.data_start
  and grp.charttime < iid.data_end
order by grp.hadm_id, grp.charttime;
