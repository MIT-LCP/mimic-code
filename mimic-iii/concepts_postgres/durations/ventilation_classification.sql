-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.ventilation_classification; CREATE TABLE mimiciii_derived.ventilation_classification AS
/* Identify The presence of a mechanical ventilation using settings */
SELECT
  icustay_id,
  charttime, /* case statement determining whether it is an instance of mech vent */
  MAX(
    CASE
      WHEN itemid IS NULL OR value IS NULL
      THEN 0 /* can't have null values */
      WHEN itemid = 720 AND value <> 'Other/Remarks'
      THEN 1 /* VentTypeRecorded */
      WHEN itemid = 223848 AND value <> 'Other'
      THEN 1
      WHEN itemid = 223849
      THEN 1 /* ventilator mode */
      WHEN itemid = 467 AND value = 'Ventilator'
      THEN 1 /* O2 delivery device == ventilator */
      WHEN itemid IN (
        445,
        448,
        449,
        450,
        1340,
        1486,
        1600,
        224687, /* minute volume */
        639,
        654,
        681,
        682,
        683,
        684,
        224685,
        224684,
        224686, /* tidal volume */
        218,
        436,
        535,
        444,
        459,
        224697,
        224695,
        224696,
        224746,
        224747, /* High/Low/Peak/Mean/Neg insp force ("RespPressure") */
        221,
        1,
        1211,
        1655,
        2000,
        226873,
        224738,
        224419,
        224750,
        227187, /* Insp pressure */
        543, /* PlateauPressure */
        5865,
        5866,
        224707,
        224709,
        224705,
        224706, /* APRV pressure */
        60,
        437,
        505,
        506,
        686,
        220339,
        224700, /* PEEP */
        3459, /* high pressure relief */
        501,
        502,
        503,
        224702, /* PCV */
        223,
        667,
        668,
        669,
        670,
        671,
        672, /* TCPCV */
        224701 /* PSVlevel */
      )
      THEN 1
      ELSE 0
    END
  ) AS MechVent,
  MAX(
    CASE
      WHEN itemid = 226732
      AND value IN (
        'Nasal cannula', /* 153714 observations */
        'Face tent', /* 24601 observations */
        'Aerosol-cool', /* 24560 observations */
        'Trach mask ', /* 16435 observations */
        'High flow neb', /* 10785 observations */
        'Non-rebreather', /* 5182 observations */
        'Venti mask ', /* 1947 observations */
        'Medium conc mask ', /* 1888 observations */
        'T-piece', /* 1135 observations */
        'High flow nasal cannula', /* 925 observations */
        'Ultrasonic neb', /* 9 observations */
        'Vapomist' /* 3 observations */
      )
      THEN 1
      WHEN itemid = 467
      AND value IN (
        'Cannula', /* 278252 observations */
        'Nasal Cannula', /* 248299 observations */
        'Face Tent', /* 'None', -- 95498 observations */ /* 35766 observations */
        'Aerosol-Cool', /* 33919 observations */
        'Trach Mask', /* 32655 observations */
        'Hi Flow Neb', /* 14070 observations */
        'Non-Rebreather', /* 10856 observations */
        'Venti Mask', /* 4279 observations */
        'Medium Conc Mask', /* 2114 observations */
        'Vapotherm', /* 1655 observations */
        'T-Piece', /* 779 observations */
        'Hood', /* 670 observations */
        'Hut', /* 150 observations */
        'TranstrachealCat', /* 78 observations */
        'Heated Neb', /* 37 observations */
        'Ultrasonic Neb' /* 2 observations */
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
  AND /* exclude rows marked as error */ (
    ce.error <> 1 OR ce.error IS NULL
  )
  AND itemid IN (
    720, /* the below are settings used to indicate ventilation */
    223849, /* vent mode */
    223848, /* vent type */
    445,
    448,
    449,
    450,
    1340,
    1486,
    1600,
    224687, /* minute volume */
    639,
    654,
    681,
    682,
    683,
    684,
    224685,
    224684,
    224686, /* tidal volume */
    218,
    436,
    535,
    444,
    224697,
    224695,
    224696,
    224746,
    224747, /* High/Low/Peak/Mean ("RespPressure") */
    221,
    1,
    1211,
    1655,
    2000,
    226873,
    224738,
    224419,
    224750,
    227187, /* Insp pressure */
    543, /* PlateauPressure */
    5865,
    5866,
    224707,
    224709,
    224705,
    224706, /* APRV pressure */
    60,
    437,
    505,
    506,
    686,
    220339,
    224700, /* PEEP */
    3459, /* high pressure relief */
    501,
    502,
    503,
    224702, /* PCV */
    223,
    667,
    668,
    669,
    670,
    671,
    672, /* TCPCV */
    224701, /* PSVlevel */ /* the below are settings used to indicate extubation */
    640, /* extubated */ /* the below indicate oxygen/NIV, i.e. the end of a mechanical vent event */
    468, /* O2 Delivery Device#2 */
    469, /* O2 Delivery Mode */
    470, /* O2 Flow (lpm) */
    471, /* O2 Flow (lpm) #2 */
    227287, /* O2 Flow (additional cannula) */
    226732, /* O2 Delivery Device(s) */
    223834, /* O2 Flow */ /* used in both oxygen + vent calculation */
    467 /* O2 Delivery Device */
  )
GROUP BY
  icustay_id,
  charttime
UNION
/* add in the extubation flags from procedureevents_mv */ /* note that we only need the start time for the extubation */ /* (extubation is always charted as ending 1 minute after it started) */
SELECT
  icustay_id,
  starttime AS charttime,
  0 AS MechVent,
  0 AS OxygenTherapy,
  1 AS Extubated,
  CASE WHEN itemid = 225468 THEN 1 ELSE 0 END AS SelfExtubated
FROM mimiciii.procedureevents_mv
WHERE
  itemid IN (
    227194, /* "Extubation" */
    225468, /* "Unplanned Extubation (patient-initiated)" */
    225477 /* "Unplanned Extubation (non-patient initiated)" */
  )