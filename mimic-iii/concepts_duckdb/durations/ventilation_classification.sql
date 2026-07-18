-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.ventilation_classification; CREATE TABLE mimiciii_derived.ventilation_classification AS
SELECT
  icustay_id,
  charttime,
  MAX(
    CASE
      WHEN itemid IS NULL OR value IS NULL
      THEN 0
      WHEN itemid = 720 AND value <> 'Other/Remarks'
      THEN 1
      WHEN itemid = 223848 AND value <> 'Other'
      THEN 1
      WHEN itemid = 223849
      THEN 1
      WHEN itemid = 467 AND value = 'Ventilator'
      THEN 1
      WHEN itemid IN (
        445,
        448,
        449,
        450,
        1340,
        1486,
        1600,
        224687,
        639,
        654,
        681,
        682,
        683,
        684,
        224685,
        224684,
        224686,
        218,
        436,
        535,
        444,
        459,
        224697,
        224695,
        224696,
        224746,
        224747,
        221,
        1,
        1211,
        1655,
        2000,
        226873,
        224738,
        224419,
        224750,
        227187,
        543,
        5865,
        5866,
        224707,
        224709,
        224705,
        224706,
        60,
        437,
        505,
        506,
        686,
        220339,
        224700,
        3459,
        501,
        502,
        503,
        224702,
        223,
        667,
        668,
        669,
        670,
        671,
        672,
        224701
      )
      THEN 1
      ELSE 0
    END
  ) AS MechVent,
  MAX(
    CASE
      WHEN itemid = 226732
      AND value IN (
        'Nasal cannula',
        'Face tent',
        'Aerosol-cool',
        'Trach mask ',
        'High flow neb',
        'Non-rebreather',
        'Venti mask ',
        'Medium conc mask ',
        'T-piece',
        'High flow nasal cannula',
        'Ultrasonic neb',
        'Vapomist'
      )
      THEN 1
      WHEN itemid = 467
      AND value IN (
        'Cannula',
        'Nasal Cannula',
        'Face Tent',
        'Aerosol-Cool',
        'Trach Mask',
        'Hi Flow Neb',
        'Non-Rebreather',
        'Venti Mask',
        'Medium Conc Mask',
        'Vapotherm',
        'T-Piece',
        'Hood',
        'Hut',
        'TranstrachealCat',
        'Heated Neb',
        'Ultrasonic Neb'
      )
      THEN 1
      ELSE 0
    END
  ) AS OxygenTherapy,
  MAX(
    CASE
      WHEN itemid IS NULL OR value IS NULL
      THEN 0
      WHEN itemid = 640 AND value = 'Extubated'
      THEN 1
      WHEN itemid = 640 AND value = 'Self Extubation'
      THEN 1
      ELSE 0
    END
  ) AS Extubated,
  MAX(
    CASE
      WHEN itemid IS NULL OR value IS NULL
      THEN 0
      WHEN itemid = 640 AND value = 'Self Extubation'
      THEN 1
      ELSE 0
    END
  ) AS SelfExtubated
FROM mimiciii.chartevents AS ce
WHERE
  NOT ce.value IS NULL
  AND (
    ce.error <> 1 OR ce.error IS NULL
  )
  AND itemid IN (
    720,
    223849,
    223848,
    445,
    448,
    449,
    450,
    1340,
    1486,
    1600,
    224687,
    639,
    654,
    681,
    682,
    683,
    684,
    224685,
    224684,
    224686,
    218,
    436,
    535,
    444,
    224697,
    224695,
    224696,
    224746,
    224747,
    221,
    1,
    1211,
    1655,
    2000,
    226873,
    224738,
    224419,
    224750,
    227187,
    543,
    5865,
    5866,
    224707,
    224709,
    224705,
    224706,
    60,
    437,
    505,
    506,
    686,
    220339,
    224700,
    3459,
    501,
    502,
    503,
    224702,
    223,
    667,
    668,
    669,
    670,
    671,
    672,
    224701,
    640,
    468,
    469,
    470,
    471,
    227287,
    226732,
    223834,
    467
  )
GROUP BY
  icustay_id,
  charttime
UNION
SELECT
  icustay_id,
  starttime AS charttime,
  0 AS MechVent,
  0 AS OxygenTherapy,
  1 AS Extubated,
  CASE WHEN itemid = 225468 THEN 1 ELSE 0 END AS SelfExtubated
FROM mimiciii.procedureevents_mv
WHERE
  itemid IN (227194, 225468, 225477)