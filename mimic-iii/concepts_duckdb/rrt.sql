-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.rrt; CREATE TABLE mimiciii_derived.rrt AS
WITH cv_ce AS (
  SELECT
    ie.icustay_id,
    MAX(
      CASE
        WHEN ce.itemid IN (152, 148, 149, 146, 147, 151, 150) AND NOT value IS NULL
        THEN 1
        WHEN ce.itemid IN (229, 235, 241, 247, 253, 259, 265, 271) AND value = 'Dialysis Line'
        THEN 1
        WHEN ce.itemid = 466 AND value = 'Dialysis RN'
        THEN 1
        WHEN ce.itemid = 927 AND value = 'Dialysis Solutions'
        THEN 1
        WHEN ce.itemid = 6250 AND value = 'dialys'
        THEN 1
        WHEN ce.itemid = 917
        AND value IN (
          '+ INITIATE DIALYSIS',
          'BLEEDING FROM DIALYSIS CATHETER',
          'FAILED DIALYSIS CATH.',
          'FEBRILE SYNDROME;DIALYSIS',
          'HYPOTENSION WITH HEMODIALYSIS',
          'HYPOTENSION.GLOGGED DIALYSIS',
          'INFECTED DIALYSIS CATHETER'
        )
        THEN 1
        WHEN ce.itemid = 582
        AND value IN (
          'CAVH Start',
          'CAVH D/C',
          'CVVHD Start',
          'CVVHD D/C',
          'Hemodialysis st',
          'Hemodialysis end'
        )
        THEN 1
        ELSE 0
      END
    ) AS RRT
  FROM mimiciii.icustays AS ie
  INNER JOIN mimiciii.chartevents AS ce
    ON ie.icustay_id = ce.icustay_id
    AND ce.itemid IN (
      152,
      148,
      149,
      146,
      147,
      151,
      150,
      7949,
      229,
      235,
      241,
      247,
      253,
      259,
      265,
      271,
      582,
      466,
      917,
      927,
      6250
    )
    AND NOT ce.value IS NULL
  WHERE
    ie.dbsource = 'carevue' AND (
      ce.error IS NULL OR ce.error = 0
    )
  GROUP BY
    ie.icustay_id
), cv_ie AS (
  SELECT
    icustay_id,
    1 AS RRT
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
  GROUP BY
    icustay_id
), cv_oe AS (
  SELECT
    icustay_id,
    1 AS RRT
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
  GROUP BY
    icustay_id
), mv_ce AS (
  SELECT
    icustay_id,
    1 AS RRT
  FROM mimiciii.chartevents AS ce
  WHERE
    itemid IN (
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
    AND ce.valuenum > 0
    AND (
      ce.error IS NULL OR ce.error = 0
    )
  GROUP BY
    icustay_id
), mv_ie AS (
  SELECT
    icustay_id,
    1 AS RRT
  FROM mimiciii.inputevents_mv
  WHERE
    itemid IN (227536, 227525) AND amount > 0
  GROUP BY
    icustay_id
), mv_de AS (
  SELECT
    icustay_id,
    1 AS RRT
  FROM mimiciii.datetimeevents
  WHERE
    itemid IN (225318, 225319, 225321, 225322, 225324)
  GROUP BY
    icustay_id
), mv_pe AS (
  SELECT
    icustay_id,
    1 AS RRT
  FROM mimiciii.procedureevents_mv
  WHERE
    itemid IN (225441, 225802, 225803, 225805, 224270, 225809, 225955, 225436)
  GROUP BY
    icustay_id
)
SELECT
  ie.subject_id,
  ie.hadm_id,
  ie.icustay_id,
  CASE
    WHEN cv_ce.RRT = 1
    THEN 1
    WHEN cv_ie.RRT = 1
    THEN 1
    WHEN cv_oe.RRT = 1
    THEN 1
    WHEN mv_ce.RRT = 1
    THEN 1
    WHEN mv_ie.RRT = 1
    THEN 1
    WHEN mv_de.RRT = 1
    THEN 1
    WHEN mv_pe.RRT = 1
    THEN 1
    ELSE 0
  END AS RRT
FROM mimiciii.icustays AS ie
LEFT JOIN cv_ce
  ON ie.icustay_id = cv_ce.icustay_id
LEFT JOIN cv_ie
  ON ie.icustay_id = cv_ie.icustay_id
LEFT JOIN cv_oe
  ON ie.icustay_id = cv_oe.icustay_id
LEFT JOIN mv_ce
  ON ie.icustay_id = mv_ce.icustay_id
LEFT JOIN mv_ie
  ON ie.icustay_id = mv_ie.icustay_id
LEFT JOIN mv_de
  ON ie.icustay_id = mv_de.icustay_id
LEFT JOIN mv_pe
  ON ie.icustay_id = mv_pe.icustay_id
ORDER BY
  ie.icustay_id NULLS FIRST