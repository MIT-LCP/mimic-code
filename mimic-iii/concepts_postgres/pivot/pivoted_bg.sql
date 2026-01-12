-- =====================================================================
-- PostgreSQL version of BigQuery pivoted-bg.sql (MIMIC-III)
-- Purpose: Pivot blood gas / chemistry values from labevents, and assign
--          them to an icustay_id using fuzzy ICU boundaries.
--
-- Expected schemas (recommended for PR):
--   mimiciii_clinical: raw MIMIC-III tables (icustays, labevents, admissions)
--   mimiciii_derived : derived concepts output schema (where this table lives)
--
-- Dependencies:
--   - postgres-functions.sql should be loaded (for DATETIME_ADD/SUB/DIFF)
--     NOTE: This script only uses DATETIME_ADD/SUB/DIFF style patterns,
--           but is also valid if you replace them with native +/- intervals.
--
-- Output table name (suggested):
--   mimiciii_derived.pivoted_bg
-- =====================================================================

DROP TABLE IF EXISTS mimiciii_derived.pivoted_bg;

CREATE TABLE mimiciii_derived.pivoted_bg AS
WITH i AS
(
  SELECT
      subject_id
    , icustay_id
    , intime
    , outtime
    , LAG(outtime) OVER (PARTITION BY subject_id ORDER BY intime)  AS outtime_lag
    , LEAD(intime) OVER (PARTITION BY subject_id ORDER BY intime)  AS intime_lead
  FROM mimiciii_clinical.icustays
)
, iid_assign AS
(
  SELECT
      i.subject_id
    , i.icustay_id
    , CASE
        WHEN i.outtime_lag IS NOT NULL
         AND i.outtime_lag > (i.intime - INTERVAL '24' HOUR)
        THEN i.intime
           - (INTERVAL '1' HOUR
              * CAST(ROUND( (EXTRACT(EPOCH FROM (i.intime - i.outtime_lag)) / 3600.0) / 2.0 ) AS BIGINT))
        ELSE i.intime - INTERVAL '12' HOUR
      END AS data_start
    , CASE
        WHEN i.intime_lead IS NOT NULL
         AND i.intime_lead < (i.outtime + INTERVAL '24' HOUR)
        THEN i.outtime
           + (INTERVAL '1' MINUTE
              * CAST(ROUND( (EXTRACT(EPOCH FROM (i.intime_lead - i.outtime)) / 60.0) / 2.0 ) AS BIGINT))
        ELSE i.outtime + INTERVAL '12' HOUR
      END AS data_end
  FROM i
)
, pvt AS
(
  SELECT
      le.hadm_id
    , CASE
        WHEN le.itemid = 50800 THEN 'SPECIMEN'
        WHEN le.itemid = 50801 THEN 'AADO2'
        WHEN le.itemid = 50802 THEN 'BASEEXCESS'
        WHEN le.itemid = 50803 THEN 'BICARBONATE'
        WHEN le.itemid = 50804 THEN 'TOTALCO2'
        WHEN le.itemid = 50805 THEN 'CARBOXYHEMOGLOBIN'
        WHEN le.itemid = 50806 THEN 'CHLORIDE'
        WHEN le.itemid = 50808 THEN 'CALCIUM'
        WHEN le.itemid = 50809 THEN 'GLUCOSE'
        WHEN le.itemid = 50810 THEN 'HEMATOCRIT'
        WHEN le.itemid = 50811 THEN 'HEMOGLOBIN'
        WHEN le.itemid = 50812 THEN 'INTUBATED'
        WHEN le.itemid = 50813 THEN 'LACTATE'
        WHEN le.itemid = 50814 THEN 'METHEMOGLOBIN'
        WHEN le.itemid = 50815 THEN 'O2FLOW'
        WHEN le.itemid = 50816 THEN 'FIO2'
        WHEN le.itemid = 50817 THEN 'SO2'
        WHEN le.itemid = 50818 THEN 'PCO2'
        WHEN le.itemid = 50819 THEN 'PEEP'
        WHEN le.itemid = 50820 THEN 'PH'
        WHEN le.itemid = 50821 THEN 'PO2'
        WHEN le.itemid = 50822 THEN 'POTASSIUM'
        WHEN le.itemid = 50823 THEN 'REQUIREDO2'
        WHEN le.itemid = 50824 THEN 'SODIUM'
        WHEN le.itemid = 50825 THEN 'TEMPERATURE'
        WHEN le.itemid = 50826 THEN 'TIDALVOLUME'
        WHEN le.itemid = 50827 THEN 'VENTILATIONRATE'
        WHEN le.itemid = 50828 THEN 'VENTILATOR'
        ELSE NULL
      END AS label
    , le.charttime
    , le.value
    , CASE
        WHEN le.valuenum IS NULL THEN NULL
        WHEN le.valuenum <= 0 THEN NULL
        WHEN le.itemid = 50810 AND le.valuenum > 100 THEN NULL          -- hematocrit
        WHEN le.itemid = 50816 AND le.valuenum < 20 THEN NULL           -- fio2 lower bound
        WHEN le.itemid = 50816 AND le.valuenum > 100 THEN NULL          -- fio2 upper bound
        WHEN le.itemid = 50817 AND le.valuenum > 100 THEN NULL          -- o2 sat
        WHEN le.itemid = 50815 AND le.valuenum > 70 THEN NULL           -- o2 flow
        WHEN le.itemid = 50821 AND le.valuenum > 800 THEN NULL          -- po2
        ELSE le.valuenum
      END AS valuenum
  FROM mimiciii_clinical.labevents le
  WHERE le.itemid IN
  (
      50800, 50801, 50802, 50803, 50804, 50805, 50806, 50807, 50808, 50809
    , 50810, 50811, 50812, 50813, 50814, 50815, 50816, 50817, 50818, 50819
    , 50820, 50821, 50822, 50823, 50824, 50825, 50826, 50827, 50828
    , 51545
  )
)
, grp AS
(
  SELECT
      pvt.hadm_id
    , pvt.charttime
    , MAX(CASE WHEN label = 'SPECIMEN' THEN value ELSE NULL END) AS specimen
    , AVG(CASE WHEN label = 'AADO2' THEN valuenum ELSE NULL END) AS aado2
    , AVG(CASE WHEN label = 'BASEEXCESS' THEN valuenum ELSE NULL END) AS baseexcess
    , AVG(CASE WHEN label = 'BICARBONATE' THEN valuenum ELSE NULL END) AS bicarbonate
    , AVG(CASE WHEN label = 'TOTALCO2' THEN valuenum ELSE NULL END) AS totalco2
    , AVG(CASE WHEN label = 'CARBOXYHEMOGLOBIN' THEN valuenum ELSE NULL END) AS carboxyhemoglobin
    , AVG(CASE WHEN label = 'CHLORIDE' THEN valuenum ELSE NULL END) AS chloride
    , AVG(CASE WHEN label = 'CALCIUM' THEN valuenum ELSE NULL END) AS calcium
    , AVG(CASE WHEN label = 'GLUCOSE' THEN valuenum ELSE NULL END) AS glucose
    , AVG(CASE WHEN label = 'HEMATOCRIT' THEN valuenum ELSE NULL END) AS hematocrit
    , AVG(CASE WHEN label = 'HEMOGLOBIN' THEN valuenum ELSE NULL END) AS hemoglobin
    , AVG(CASE WHEN label = 'INTUBATED' THEN valuenum ELSE NULL END) AS intubated
    , AVG(CASE WHEN label = 'LACTATE' THEN valuenum ELSE NULL END) AS lactate
    , AVG(CASE WHEN label = 'METHEMOGLOBIN' THEN valuenum ELSE NULL END) AS methemoglobin
    , AVG(CASE WHEN label = 'O2FLOW' THEN valuenum ELSE NULL END) AS o2flow
    , AVG(CASE WHEN label = 'FIO2' THEN valuenum ELSE NULL END) AS fio2
    , AVG(CASE WHEN label = 'SO2' THEN valuenum ELSE NULL END) AS so2
    , AVG(CASE WHEN label = 'PCO2' THEN valuenum ELSE NULL END) AS pco2
    , AVG(CASE WHEN label = 'PEEP' THEN valuenum ELSE NULL END) AS peep
    , AVG(CASE WHEN label = 'PH' THEN valuenum ELSE NULL END) AS ph
    , AVG(CASE WHEN label = 'PO2' THEN valuenum ELSE NULL END) AS po2
    , AVG(CASE WHEN label = 'POTASSIUM' THEN valuenum ELSE NULL END) AS potassium
    , AVG(CASE WHEN label = 'REQUIREDO2' THEN valuenum ELSE NULL END) AS requiredo2
    , AVG(CASE WHEN label = 'SODIUM' THEN valuenum ELSE NULL END) AS sodium
    , AVG(CASE WHEN label = 'TEMPERATURE' THEN valuenum ELSE NULL END) AS temperature
    , AVG(CASE WHEN label = 'TIDALVOLUME' THEN valuenum ELSE NULL END) AS tidalvolume
    , MAX(CASE WHEN label = 'VENTILATIONRATE' THEN valuenum ELSE NULL END) AS ventilationrate
    , MAX(CASE WHEN label = 'VENTILATOR' THEN valuenum ELSE NULL END) AS ventilator
    , SUM(CASE WHEN label = 'SPECIMEN' THEN 1 ELSE 0 END) AS specimen_ct
  FROM pvt
  GROUP BY pvt.hadm_id, pvt.charttime
  HAVING SUM(CASE WHEN label = 'SPECIMEN' THEN 1 ELSE 0 END) < 2
)
SELECT
    iid.icustay_id
  , grp.hadm_id
  , grp.charttime
  , grp.specimen
  , grp.aado2
  , grp.baseexcess
  , grp.bicarbonate
  , grp.totalco2
  , grp.carboxyhemoglobin
  , grp.chloride
  , grp.calcium
  , grp.glucose
  , grp.hematocrit
  , grp.hemoglobin
  , grp.intubated
  , grp.lactate
  , grp.methemoglobin
  , grp.o2flow
  , grp.fio2
  , grp.so2
  , grp.pco2
  , grp.peep
  , grp.ph
  , grp.po2
  , grp.potassium
  , grp.requiredo2
  , grp.sodium
  , grp.temperature
  , grp.tidalvolume
  , grp.ventilationrate
  , grp.ventilator
FROM grp
INNER JOIN mimiciii_clinical.admissions adm
  ON grp.hadm_id = adm.hadm_id
LEFT JOIN iid_assign iid
  ON adm.subject_id = iid.subject_id
 AND grp.charttime >= iid.data_start
 AND grp.charttime <  iid.data_end
ORDER BY grp.hadm_id, grp.charttime;

-- Suggested indexes (optional, but helps downstream joins a lot):
-- CREATE INDEX IF NOT EXISTS idx_pivoted_bg_icustay_charttime
--   ON mimiciii_derived.pivoted_bg (icustay_id, charttime);
-- CREATE INDEX IF NOT EXISTS idx_pivoted_bg_hadm_charttime
--   ON mimiciii_derived.pivoted_bg (hadm_id, charttime);
