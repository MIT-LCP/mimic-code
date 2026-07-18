-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.blood_gas_first_day; CREATE TABLE mimiciii_derived.blood_gas_first_day AS
WITH pvt AS (
  SELECT
    ie.subject_id,
    ie.hadm_id,
    ie.icustay_id,
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
      THEN 'SO2'
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
    value,
    CASE
      WHEN valuenum <= 0 AND itemid <> 50802
      THEN NULL
      WHEN itemid = 50810 AND valuenum > 100
      THEN NULL
      WHEN itemid = 50816 AND valuenum < 20
      THEN NULL
      WHEN itemid = 50816 AND valuenum > 100
      THEN NULL
      WHEN itemid = 50817 AND valuenum > 100
      THEN NULL
      WHEN itemid = 50815 AND valuenum > 70
      THEN NULL
      WHEN itemid = 50821 AND valuenum > 800
      THEN NULL
      ELSE valuenum
    END AS valuenum
  FROM mimiciii.icustays AS ie
  LEFT JOIN mimiciii.labevents AS le
    ON le.subject_id = ie.subject_id
    AND le.hadm_id = ie.hadm_id
    AND le.charttime BETWEEN (
      ie.intime - INTERVAL '6' HOUR
    ) AND (
      ie.intime + INTERVAL '1' DAY
    )
    AND le.ITEMID IN (
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
)
SELECT
  pvt.SUBJECT_ID,
  pvt.HADM_ID,
  pvt.ICUSTAY_ID,
  pvt.CHARTTIME,
  MAX(CASE WHEN label = 'SPECIMEN' THEN value ELSE NULL END) AS specimen,
  MAX(CASE WHEN label = 'AADO2' THEN valuenum ELSE NULL END) AS aado2,
  MAX(CASE WHEN label = 'BASEEXCESS' THEN valuenum ELSE NULL END) AS baseexcess,
  MAX(CASE WHEN label = 'BICARBONATE' THEN valuenum ELSE NULL END) AS bicarbonate,
  MAX(CASE WHEN label = 'TOTALCO2' THEN valuenum ELSE NULL END) AS totalco2,
  MAX(CASE WHEN label = 'CARBOXYHEMOGLOBIN' THEN valuenum ELSE NULL END) AS carboxyhemoglobin,
  MAX(CASE WHEN label = 'CHLORIDE' THEN valuenum ELSE NULL END) AS chloride,
  MAX(CASE WHEN label = 'CALCIUM' THEN valuenum ELSE NULL END) AS calcium,
  MAX(CASE WHEN label = 'GLUCOSE' THEN valuenum ELSE NULL END) AS glucose,
  MAX(CASE WHEN label = 'HEMATOCRIT' THEN valuenum ELSE NULL END) AS hematocrit,
  MAX(CASE WHEN label = 'HEMOGLOBIN' THEN valuenum ELSE NULL END) AS hemoglobin,
  MAX(CASE WHEN label = 'INTUBATED' THEN valuenum ELSE NULL END) AS intubated,
  MAX(CASE WHEN label = 'LACTATE' THEN valuenum ELSE NULL END) AS lactate,
  MAX(CASE WHEN label = 'METHEMOGLOBIN' THEN valuenum ELSE NULL END) AS methemoglobin,
  MAX(CASE WHEN label = 'O2FLOW' THEN valuenum ELSE NULL END) AS o2flow,
  MAX(CASE WHEN label = 'FIO2' THEN valuenum ELSE NULL END) AS fio2,
  MAX(CASE WHEN label = 'SO2' THEN valuenum ELSE NULL END) AS so2,
  MAX(CASE WHEN label = 'PCO2' THEN valuenum ELSE NULL END) AS pco2,
  MAX(CASE WHEN label = 'PEEP' THEN valuenum ELSE NULL END) AS peep,
  MAX(CASE WHEN label = 'PH' THEN valuenum ELSE NULL END) AS ph,
  MAX(CASE WHEN label = 'PO2' THEN valuenum ELSE NULL END) AS po2,
  MAX(CASE WHEN label = 'POTASSIUM' THEN valuenum ELSE NULL END) AS potassium,
  MAX(CASE WHEN label = 'REQUIREDO2' THEN valuenum ELSE NULL END) AS requiredo2,
  MAX(CASE WHEN label = 'SODIUM' THEN valuenum ELSE NULL END) AS sodium,
  MAX(CASE WHEN label = 'TEMPERATURE' THEN valuenum ELSE NULL END) AS temperature,
  MAX(CASE WHEN label = 'TIDALVOLUME' THEN valuenum ELSE NULL END) AS tidalvolume,
  MAX(CASE WHEN label = 'VENTILATIONRATE' THEN valuenum ELSE NULL END) AS ventilationrate,
  MAX(CASE WHEN label = 'VENTILATOR' THEN valuenum ELSE NULL END) AS ventilator
FROM pvt
GROUP BY
  pvt.subject_id,
  pvt.hadm_id,
  pvt.icustay_id,
  pvt.CHARTTIME
ORDER BY
  pvt.subject_id NULLS FIRST,
  pvt.hadm_id NULLS FIRST,
  pvt.icustay_id NULLS FIRST,
  pvt.CHARTTIME NULLS FIRST