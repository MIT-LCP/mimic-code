-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_bg; CREATE TABLE mimiciii_derived.pivoted_bg AS
/* The aim of this query is to pivot entries related to blood gases and */ /* chemistry values which were found in LABEVENTS */ /* create a table which has fuzzy boundaries on ICU admission */ /* involves first creating a lag/lead version of intime/outtime */
WITH i AS (
  SELECT
    subject_id,
    icustay_id,
    intime,
    outtime,
    LAG(outtime) OVER (PARTITION BY subject_id ORDER BY intime NULLS FIRST) AS outtime_lag,
    LEAD(intime) OVER (PARTITION BY subject_id ORDER BY intime NULLS FIRST) AS intime_lead
  FROM mimiciii.icustays
), iid_assign AS (
  SELECT
    i.subject_id,
    i.icustay_id, /* this rule is: */ /*  if there are two hospitalizations within 24 hours, set the start/stop */ /*  time as half way between the two admissions */
    CASE
      WHEN NOT i.outtime_lag IS NULL AND i.outtime_lag > (
        i.intime - INTERVAL '24' HOUR
      )
      THEN i.intime - CAST(ROUND(
        (
          CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('hour', i.intime) - DATE_TRUNC('hour', i.outtime_lag)) / 3600 AS BIGINT) AS DOUBLE PRECISION) / 2
        )
      ) AS BIGINT) * INTERVAL '1' HOUR
      ELSE i.intime - INTERVAL '12' HOUR
    END AS data_start,
    CASE
      WHEN NOT i.intime_lead IS NULL
      AND i.intime_lead < (
        i.outtime + INTERVAL '24' HOUR
      )
      THEN i.outtime + CAST(ROUND(
        (
          CAST(CAST(EXTRACT(EPOCH FROM DATE_TRUNC('minute', i.intime_lead) - DATE_TRUNC('minute', i.outtime)) / 60 AS BIGINT) AS DOUBLE PRECISION) / 2
        )
      ) AS BIGINT) * INTERVAL '1' MINUTE
      ELSE (
        i.outtime + INTERVAL '12' HOUR
      )
    END AS data_end
  FROM i
), pvt AS (
  SELECT
    le.hadm_id, /* here we assign labels to ITEMIDs */ /* this also fuses together multiple ITEMIDs containing the same data */
    CASE
      WHEN itemid = 50800
      THEN 'SPECIMEN'
      WHEN itemid = 50801
      THEN 'AADO2'
      WHEN itemid = 50802
      THEN 'BASEEXCESS'
      WHEN itemid = 50803
      THEN 'BICARBONATE'
      WHEN itemid = 50804
      THEN 'TOTALCO2'
      WHEN itemid = 50805
      THEN 'CARBOXYHEMOGLOBIN'
      WHEN itemid = 50806
      THEN 'CHLORIDE'
      WHEN itemid = 50808
      THEN 'CALCIUM'
      WHEN itemid = 50809
      THEN 'GLUCOSE'
      WHEN itemid = 50810
      THEN 'HEMATOCRIT'
      WHEN itemid = 50811
      THEN 'HEMOGLOBIN'
      WHEN itemid = 50812
      THEN 'INTUBATED'
      WHEN itemid = 50813
      THEN 'LACTATE'
      WHEN itemid = 50814
      THEN 'METHEMOGLOBIN'
      WHEN itemid = 50815
      THEN 'O2FLOW'
      WHEN itemid = 50816
      THEN 'FIO2'
      WHEN itemid = 50817
      THEN 'SO2' /* OXYGENSATURATION */
      WHEN itemid = 50818
      THEN 'PCO2'
      WHEN itemid = 50819
      THEN 'PEEP'
      WHEN itemid = 50820
      THEN 'PH'
      WHEN itemid = 50821
      THEN 'PO2'
      WHEN itemid = 50822
      THEN 'POTASSIUM'
      WHEN itemid = 50823
      THEN 'REQUIREDO2'
      WHEN itemid = 50824
      THEN 'SODIUM'
      WHEN itemid = 50825
      THEN 'TEMPERATURE'
      WHEN itemid = 50826
      THEN 'TIDALVOLUME'
      WHEN itemid = 50827
      THEN 'VENTILATIONRATE'
      WHEN itemid = 50828
      THEN 'VENTILATOR'
      ELSE NULL
    END AS label,
    charttime,
    value, /* add in some sanity checks on the values */
    CASE
      WHEN valuenum <= 0
      THEN NULL
      WHEN itemid = 50810 AND valuenum > 100
      THEN NULL /* hematocrit */
      WHEN itemid = 50816 AND valuenum < 20
      THEN NULL
      WHEN itemid = 50816 AND valuenum > 100
      THEN NULL
      WHEN itemid = 50817 AND valuenum > 100
      THEN NULL /* O2 sat */
      WHEN itemid = 50815 AND valuenum > 70
      THEN NULL /* O2 flow */
      WHEN itemid = 50821 AND valuenum > 800
      THEN NULL /* PO2 */
      ELSE valuenum
    END AS valuenum
  FROM mimiciii.labevents AS le
  WHERE
    le.ITEMID IN (
      50800,
      50801,
      50802,
      50803,
      50804,
      50805,
      50806,
      50807,
      50808,
      50809,
      50810,
      50811,
      50812,
      50813,
      50814,
      50815,
      50816,
      50817,
      50818,
      50819,
      50820,
      50821,
      50822,
      50823,
      50824,
      50825,
      50826,
      50827,
      50828,
      51545
    )
), grp AS (
  SELECT
    pvt.hadm_id,
    pvt.charttime,
    MAX(CASE WHEN label = 'SPECIMEN' THEN value ELSE NULL END) AS specimen,
    AVG(CASE WHEN label = 'AADO2' THEN valuenum ELSE NULL END) AS aado2,
    AVG(CASE WHEN label = 'BASEEXCESS' THEN valuenum ELSE NULL END) AS baseexcess,
    AVG(CASE WHEN label = 'BICARBONATE' THEN valuenum ELSE NULL END) AS bicarbonate,
    AVG(CASE WHEN label = 'TOTALCO2' THEN valuenum ELSE NULL END) AS totalco2,
    AVG(CASE WHEN label = 'CARBOXYHEMOGLOBIN' THEN valuenum ELSE NULL END) AS carboxyhemoglobin,
    AVG(CASE WHEN label = 'CHLORIDE' THEN valuenum ELSE NULL END) AS chloride,
    AVG(CASE WHEN label = 'CALCIUM' THEN valuenum ELSE NULL END) AS calcium,
    AVG(CASE WHEN label = 'GLUCOSE' THEN valuenum ELSE NULL END) AS glucose,
    AVG(CASE WHEN label = 'HEMATOCRIT' THEN valuenum ELSE NULL END) AS hematocrit,
    AVG(CASE WHEN label = 'HEMOGLOBIN' THEN valuenum ELSE NULL END) AS hemoglobin,
    AVG(CASE WHEN label = 'INTUBATED' THEN valuenum ELSE NULL END) AS intubated,
    AVG(CASE WHEN label = 'LACTATE' THEN valuenum ELSE NULL END) AS lactate,
    AVG(CASE WHEN label = 'METHEMOGLOBIN' THEN valuenum ELSE NULL END) AS methemoglobin,
    AVG(CASE WHEN label = 'O2FLOW' THEN valuenum ELSE NULL END) AS o2flow,
    AVG(CASE WHEN label = 'FIO2' THEN valuenum ELSE NULL END) AS fio2,
    AVG(CASE WHEN label = 'SO2' THEN valuenum ELSE NULL END) AS so2, /* OXYGENSATURATION */
    AVG(CASE WHEN label = 'PCO2' THEN valuenum ELSE NULL END) AS pco2,
    AVG(CASE WHEN label = 'PEEP' THEN valuenum ELSE NULL END) AS peep,
    AVG(CASE WHEN label = 'PH' THEN valuenum ELSE NULL END) AS ph,
    AVG(CASE WHEN label = 'PO2' THEN valuenum ELSE NULL END) AS po2,
    AVG(CASE WHEN label = 'POTASSIUM' THEN valuenum ELSE NULL END) AS potassium,
    AVG(CASE WHEN label = 'REQUIREDO2' THEN valuenum ELSE NULL END) AS requiredo2,
    AVG(CASE WHEN label = 'SODIUM' THEN valuenum ELSE NULL END) AS sodium,
    AVG(CASE WHEN label = 'TEMPERATURE' THEN valuenum ELSE NULL END) AS temperature,
    AVG(CASE WHEN label = 'TIDALVOLUME' THEN valuenum ELSE NULL END) AS tidalvolume,
    MAX(CASE WHEN label = 'VENTILATIONRATE' THEN valuenum ELSE NULL END) AS ventilationrate,
    MAX(CASE WHEN label = 'VENTILATOR' THEN valuenum ELSE NULL END) AS ventilator
  FROM pvt
  GROUP BY
    pvt.hadm_id,
    pvt.charttime
  /* remove observations if there is more than one specimen listed */ /* we do not know whether these are arterial or mixed venous, etc... */ /* happily this is a small fraction of the total number of observations */
  HAVING
    SUM(CASE WHEN label = 'SPECIMEN' THEN 1 ELSE 0 END) < 2
)
SELECT
  iid.icustay_id,
  grp.*
FROM grp
INNER JOIN mimiciii.admissions AS adm
  ON grp.hadm_id = adm.hadm_id
LEFT JOIN iid_assign AS iid
  ON adm.subject_id = iid.subject_id
  AND grp.charttime >= iid.data_start
  AND grp.charttime < iid.data_end
ORDER BY
  grp.hadm_id NULLS FIRST,
  grp.charttime NULLS FIRST