-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.oxygen_delivery; CREATE TABLE mimiciv_derived.oxygen_delivery AS
WITH ce_stg1 AS (
  SELECT
    ce.subject_id,
    ce.stay_id,
    ce.charttime,
    CASE WHEN itemid IN (223834, 227582) THEN 223834 ELSE itemid END AS itemid,
    value,
    valuenum,
    valueuom,
    storetime
  FROM mimiciv_icu.chartevents AS ce
  WHERE
    NOT ce.value IS NULL AND ce.itemid IN (223834, 227582, 227287)
), ce_stg2 AS (
  SELECT
    ce.subject_id,
    ce.stay_id,
    ce.charttime,
    itemid,
    value,
    valuenum,
    valueuom,
    ROW_NUMBER() OVER (PARTITION BY subject_id, charttime, itemid ORDER BY storetime DESC) AS rn
  FROM ce_stg1 AS ce
), o2 AS (
  SELECT
    subject_id,
    stay_id,
    charttime,
    itemid,
    value AS o2_device,
    ROW_NUMBER() OVER (PARTITION BY subject_id, charttime, itemid ORDER BY value NULLS FIRST) AS rn
  FROM mimiciv_icu.chartevents
  WHERE
    itemid = 226732
), stg AS (
  SELECT
    COALESCE(ce.subject_id, o2.subject_id) AS subject_id,
    COALESCE(ce.stay_id, o2.stay_id) AS stay_id,
    COALESCE(ce.charttime, o2.charttime) AS charttime,
    COALESCE(ce.itemid, o2.itemid) AS itemid,
    ce.value,
    ce.valuenum,
    o2.o2_device,
    o2.rn
  FROM ce_stg2 AS ce
  FULL OUTER JOIN o2
    ON ce.subject_id = o2.subject_id AND ce.charttime = o2.charttime
  WHERE
    ce.rn = 1
)
SELECT
  subject_id,
  MAX(stay_id) AS stay_id,
  charttime,
  MAX(CASE WHEN itemid = 223834 THEN valuenum ELSE NULL END) AS o2_flow,
  MAX(CASE WHEN itemid = 227287 THEN valuenum ELSE NULL END) AS o2_flow_additional,
  MAX(CASE WHEN rn = 1 THEN o2_device ELSE NULL END) AS o2_delivery_device_1,
  MAX(CASE WHEN rn = 2 THEN o2_device ELSE NULL END) AS o2_delivery_device_2,
  MAX(CASE WHEN rn = 3 THEN o2_device ELSE NULL END) AS o2_delivery_device_3,
  MAX(CASE WHEN rn = 4 THEN o2_device ELSE NULL END) AS o2_delivery_device_4
FROM stg
GROUP BY
  subject_id,
  charttime