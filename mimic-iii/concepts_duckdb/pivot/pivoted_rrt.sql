-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.pivoted_rrt; CREATE TABLE mimiciii_derived.pivoted_rrt AS
WITH ce AS (
  SELECT
    ce.icustay_id,
    ce.charttime,
    CASE
      WHEN ce.itemid IN (146, 147, 148, 149, 150, 151, 152)
      THEN 1
      WHEN ce.itemid = 582
      AND value IN (
        'CAVH Start',
        'CVVHD Start',
        'Hemodialysis st',
        'CAVH D/C',
        'CVVHD D/C',
        'Hemodialysis end',
        'Peritoneal Dial'
      )
      THEN 1
      WHEN ce.itemid IN (229, 235, 241, 247, 253, 259, 265, 271) AND value = 'Dialysis Line'
      THEN 1
      WHEN ce.itemid IN (226118, 227357, 225725)
      THEN 1
      WHEN ce.itemid IN (
        226499,
        224154,
        225810,
        225959,
        227639,
        225183,
        227438,
        224191,
        225806,
        225807,
        228004,
        228005,
        228006,
        224144,
        224145,
        224149,
        224150,
        224151,
        224152,
        224153,
        224404,
        224406,
        226457
      )
      THEN 1
      WHEN ce.itemid IN (
        224135,
        224139,
        224146,
        225323,
        225740,
        225776,
        225951,
        225952,
        225953,
        225954,
        225956,
        225958,
        225961,
        225963,
        225965,
        225976,
        225977,
        227124,
        227290,
        227638,
        227640,
        227753
      )
      THEN 1
      ELSE 0
    END AS dialysis_present,
    CASE
      WHEN ce.itemid = 582
      AND value IN ('CAVH Start', 'CVVHD Start', 'Hemodialysis st', 'Peritoneal Dial')
      THEN 1
      WHEN ce.itemid = 582 AND value IN ('CAVH D/C', 'CVVHD D/C', 'Hemodialysis end')
      THEN 0
      WHEN ce.itemid = 147 AND value = 'Yes'
      THEN 1
      WHEN ce.itemid = 225965 AND value = 'In use'
      THEN 1
      WHEN ce.itemid IN (
        146,
        226499,
        224154,
        225183,
        227438,
        224191,
        225806,
        225807,
        228004,
        228005,
        228006,
        224144,
        224145,
        224153,
        226457
      )
      THEN 1
      ELSE 0
    END AS dialysis_active,
    CASE
      WHEN ce.itemid IN (152, 227290)
      THEN CASE
        WHEN value = 'CVVH'
        THEN 'CVVH'
        WHEN value = 'CVVHD'
        THEN 'CVVHD'
        WHEN value = 'CVVHDF'
        THEN 'CVVHDF'
        WHEN value = 'SCUF'
        THEN 'SCUF'
        WHEN value = 'Peritoneal'
        THEN 'Peritoneal'
      END
      WHEN ce.itemid IN (
        225810,
        225806,
        225807,
        225810,
        227639,
        225959,
        225951,
        225952,
        225961,
        225953,
        225963,
        225965,
        227638,
        227640
      )
      THEN 'Peritoneal'
      WHEN ce.itemid IN (226499)
      THEN 'IHD'
      WHEN ce.itemid = 582
      THEN CASE
        WHEN value IN ('CAVH Start', 'CAVH D/C')
        THEN 'CAVH'
        WHEN value IN ('CVVHD Start', 'CVVHD D/C')
        THEN 'CVVHD'
        WHEN value IN ('Hemodialysis st', 'Hemodialysis end')
        THEN NULL
        ELSE NULL
      END
      ELSE NULL
    END AS dialysis_type
  FROM mimiciii.chartevents AS ce
  WHERE
    ce.itemid IN (
      152,
      146,
      147,
      148,
      149,
      150,
      151,
      582,
      229,
      235,
      241,
      247,
      253,
      259,
      265,
      271,
      226118,
      227357,
      225725,
      226499,
      224154,
      225810,
      227639,
      225183,
      227438,
      224191,
      225806,
      225807,
      228004,
      228005,
      228006,
      224144,
      224145,
      224149,
      224150,
      224151,
      224152,
      224153,
      224404,
      224406,
      226457,
      225959,
      224135,
      224139,
      224146,
      225323,
      225740,
      225776,
      225951,
      225952,
      225953,
      225954,
      225956,
      225958,
      225961,
      225963,
      225965,
      225976,
      225977,
      227124,
      227290,
      227638,
      227640,
      227753
    )
    AND NOT ce.value IS NULL
    AND NOT ce.icustay_id IS NULL
    AND COALESCE(ce.error, 0) = 0
), cv_ie AS (
  SELECT
    icustay_id,
    charttime,
    1 AS dialysis_present,
    CASE WHEN NOT itemid IN (44954) THEN 1 ELSE 0 END AS dialysis_active,
    CASE
      WHEN itemid IN (40788, 41063, 41307, 43829, 44698, 46720)
      THEN 'Peritoneal'
      WHEN itemid IN (45352, 45353)
      THEN 'CVVH'
      WHEN itemid IN (45268, 46769, 46773)
      THEN 'CVVHD'
      WHEN itemid IN (46012, 46013, 46172, 46173)
      THEN 'CVVHDF'
      ELSE NULL
    END AS dialysis_type
  FROM mimiciii.inputevents_cv
  WHERE
    itemid IN (
      40788,
      40907,
      41063,
      41147,
      41307,
      41460,
      41620,
      41711,
      41791,
      41792,
      42562,
      43829,
      44037,
      44188,
      44526,
      44527,
      44584,
      44591,
      44698,
      44927,
      44954,
      45157,
      45268,
      45352,
      45353,
      46012,
      46013,
      46172,
      46173,
      46250,
      46262,
      46292,
      46293,
      46311,
      46389,
      46574,
      46681,
      46720,
      46769,
      46773
    )
    AND amount > 0
), oe AS (
  SELECT
    icustay_id,
    charttime,
    1 AS dialysis_present,
    CASE WHEN NOT itemid IN (41897) THEN 1 ELSE 0 END AS dialysis_active,
    CASE
      WHEN itemid IN (40789, 40910, 41069, 44843, 46394)
      THEN 'Peritoneal'
      ELSE NULL
    END AS dialysis_type
  FROM mimiciii.outputevents
  WHERE
    itemid IN (
      40386,
      40425,
      40426,
      40507,
      40613,
      40624,
      40690,
      40745,
      40789,
      40881,
      40910,
      41016,
      41034,
      41069,
      41112,
      41250,
      41374,
      41417,
      41500,
      41527,
      41623,
      41635,
      41713,
      41750,
      41829,
      41842,
      41897,
      42289,
      42388,
      42464,
      42524,
      42536,
      42868,
      42928,
      42972,
      43016,
      43052,
      43098,
      43115,
      43687,
      43941,
      44027,
      44085,
      44193,
      44199,
      44216,
      44286,
      44567,
      44843,
      44845,
      44857,
      44901,
      44943,
      45479,
      45828,
      46230,
      46232,
      46394,
      46464,
      46712,
      46713,
      46715,
      46741
    )
    AND value > 0
), mv_ranges AS (
  SELECT
    icustay_id,
    starttime,
    endtime,
    1 AS dialysis_present,
    1 AS dialysis_active,
    'CRRT' AS dialysis_type
  FROM mimiciii.inputevents_mv
  WHERE
    itemid IN (227536, 227525) AND amount > 0
  UNION
  SELECT
    icustay_id,
    starttime,
    endtime,
    1 AS dialysis_present,
    CASE WHEN NOT itemid IN (224270, 225436) THEN 1 ELSE 0 END AS dialysis_active,
    CASE
      WHEN itemid = 225441
      THEN 'IHD'
      WHEN itemid = 225802
      THEN 'CRRT'
      WHEN itemid = 225803
      THEN 'CVVHD'
      WHEN itemid = 225805
      THEN 'Peritoneal'
      WHEN itemid = 225809
      THEN 'CVVHDF'
      WHEN itemid = 225955
      THEN 'SCUF'
      ELSE NULL
    END AS dialysis_type
  FROM mimiciii.procedureevents_mv
  WHERE
    itemid IN (225441, 225802, 225803, 225805, 224270, 225809, 225955, 225436)
    AND NOT value IS NULL
), stg0 AS (
  SELECT
    icustay_id,
    charttime,
    dialysis_present,
    dialysis_active,
    dialysis_type
  FROM ce
  WHERE
    dialysis_present = 1
  UNION
  SELECT
    icustay_id,
    charttime,
    dialysis_present,
    dialysis_active,
    dialysis_type
  FROM cv_ie
  WHERE
    dialysis_present = 1
  UNION
  SELECT
    icustay_id,
    charttime,
    dialysis_present,
    dialysis_active,
    dialysis_type
  FROM oe
  WHERE
    dialysis_present = 1
  UNION
  SELECT
    icustay_id,
    starttime AS charttime,
    dialysis_present,
    dialysis_active,
    dialysis_type
  FROM mv_ranges
  UNION
  SELECT
    icustay_id,
    endtime AS charttime,
    dialysis_present,
    dialysis_active,
    dialysis_type
  FROM mv_ranges
)
SELECT
  stg0.icustay_id,
  charttime,
  COALESCE(mv.dialysis_present, stg0.dialysis_present) AS dialysis_present,
  COALESCE(mv.dialysis_active, stg0.dialysis_active) AS dialysis_active,
  COALESCE(mv.dialysis_type, stg0.dialysis_type) AS dialysis_type
FROM stg0
LEFT JOIN mv_ranges AS mv
  ON stg0.icustay_id = mv.icustay_id
  AND stg0.charttime >= mv.starttime
  AND stg0.charttime <= mv.endtime
WHERE
  NOT stg0.icustay_id IS NULL
ORDER BY
  1 NULLS FIRST,
  2 NULLS FIRST