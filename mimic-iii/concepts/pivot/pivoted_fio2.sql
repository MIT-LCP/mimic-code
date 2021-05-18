with pvt as
( -- begin query that extracts the data
  select le.hadm_id
  , le.charttime
  -- here we assign labels to ITEMIDs
  -- this also fuses together multiple ITEMIDs containing the same data
    -- add in some sanity checks on the values
    , ROUND(MAX(case
        when valuenum <= 0 then null
        -- ensure FiO2 is a valid number between 21-100
        -- mistakes are rare (<100 obs out of ~100,000)
        -- there are 862 obs of valuenum == 20 - some people round down!
        -- rather than risk imputing garbage data for FiO2, we simply NULL invalid values
        when itemid = 50816 and valuenum < 20 then null
        when itemid = 50816 and valuenum > 100 then null
    ELSE valuenum END), 2) AS valuenum
    FROM `physionet-data.mimiciii_clinical.labevents` le
    where le.ITEMID = 50816
    GROUP BY le.hadm_id, le.charttime
)
, stg_fio2 as
(
  select hadm_id, charttime
    -- pre-process the FiO2s to ensure they are between 21-100%
    , ROUND(MAX(
        case
          when itemid = 223835
            then case
              when valuenum > 0 and valuenum <= 1
                then valuenum * 100
              -- improperly input data - looks like O2 flow in litres
              when valuenum > 1 and valuenum < 21
                then null
              when valuenum >= 21 and valuenum <= 100
                then valuenum
              else null end -- unphysiological
        when itemid in (3420, 3422)
        -- all these values are well formatted
            then valuenum
        when itemid = 190 and valuenum > 0.20 and valuenum < 1
        -- well formatted but not in %
            then valuenum * 100
      else null end
    ), 2) as fio2_chartevents
  FROM `physionet-data.mimiciii_clinical.chartevents`
  where ITEMID in
  (
    3420 -- FiO2
  , 190 -- FiO2 set
  , 223835 -- Inspired O2 Fraction (FiO2)
  , 3422 -- FiO2 [measured]
  )
  and valuenum > 0 and valuenum < 100
  -- exclude rows marked as error
  AND (error IS NULL OR error != 1)
  group by hadm_id, charttime
)
select
  ie.icustay_id
  , COALESCE(pvt.charttime, fi.charttime) AS charttime
  , COALESCE(pvt.valuenum, fi.fio2_chartevents) AS fio2
from 
(
    -- one row per icustay_id/charttime
    SELECT hadm_id, charttime
    from pvt
    UNION DISTINCT
    SELECT hadm_id, charttime
    from stg_fio2
) base
INNER JOIN `physionet-data.mimiciii_clinical.icustays` ie
  on base.hadm_id = ie.hadm_id
  AND base.charttime >= DATETIME_SUB(ie.intime, INTERVAL 12 HOUR)
  AND base.charttime <= DATETIME_ADD(ie.outtime, INTERVAL 12 HOUR)
LEFT JOIN pvt
  ON base.hadm_id = pvt.hadm_id
  AND base.charttime = pvt.charttime
LEFT JOIN stg_fio2 fi
  ON base.hadm_id = fi.hadm_id
  AND base.charttime = fi.charttime
ORDER BY icustay_id, charttime;