-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.crrt; CREATE TABLE mimiciv_derived.crrt AS
WITH crrt_settings AS (
  SELECT
    ce.stay_id,
    ce.charttime,
    CASE WHEN ce.itemid = 227290 THEN ce.value END AS crrt_mode,
    CASE WHEN ce.itemid = 224149 THEN ce.valuenum ELSE NULL END AS accesspressure,
    CASE WHEN ce.itemid = 224144 THEN ce.valuenum ELSE NULL END AS bloodflow,
    CASE WHEN ce.itemid = 228004 THEN ce.valuenum ELSE NULL END AS citrate,
    CASE WHEN ce.itemid = 225183 THEN ce.valuenum ELSE NULL END AS currentgoal,
    CASE WHEN ce.itemid = 225977 THEN ce.value ELSE NULL END AS dialysatefluid,
    CASE WHEN ce.itemid = 224154 THEN ce.valuenum ELSE NULL END AS dialysaterate,
    CASE WHEN ce.itemid = 224151 THEN ce.valuenum ELSE NULL END AS effluentpressure,
    CASE WHEN ce.itemid = 224150 THEN ce.valuenum ELSE NULL END AS filterpressure,
    CASE WHEN ce.itemid = 225958 THEN ce.value ELSE NULL END AS heparinconcentration,
    CASE WHEN ce.itemid = 224145 THEN ce.valuenum ELSE NULL END AS heparindose,
    CASE WHEN ce.itemid = 224191 THEN ce.valuenum ELSE NULL END AS hourlypatientfluidremoval,
    CASE WHEN ce.itemid = 228005 THEN ce.valuenum ELSE NULL END AS prefilterreplacementrate,
    CASE WHEN ce.itemid = 228006 THEN ce.valuenum ELSE NULL END AS postfilterreplacementrate,
    CASE WHEN ce.itemid = 225976 THEN ce.value ELSE NULL END AS replacementfluid,
    CASE WHEN ce.itemid = 224153 THEN ce.valuenum ELSE NULL END AS replacementrate,
    CASE WHEN ce.itemid = 224152 THEN ce.valuenum ELSE NULL END AS returnpressure,
    CASE WHEN ce.itemid = 226457 THEN ce.valuenum END AS ultrafiltrateoutput,
    CASE
      WHEN ce.itemid = 224146
      AND ce.value IN ('Active', 'Initiated', 'Reinitiated', 'New Filter')
      THEN 1
      WHEN ce.itemid = 224146 AND ce.value IN ('Recirculating', 'Discontinued')
      THEN 0
      ELSE NULL
    END AS system_active,
    CASE
      WHEN ce.itemid = 224146 AND ce.value IN ('Clots Present', 'Clots Present')
      THEN 1
      WHEN ce.itemid = 224146 AND ce.value IN ('No Clot Present', 'No Clot Present')
      THEN 0
      ELSE NULL
    END AS clots,
    CASE
      WHEN ce.itemid = 224146 AND ce.value IN ('Clots Increasing', 'Clot Increasing')
      THEN 1
      ELSE NULL
    END AS clots_increasing,
    CASE WHEN ce.itemid = 224146 AND ce.value IN ('Clotted') THEN 1 ELSE NULL END AS clotted
  FROM mimiciv_icu.chartevents AS ce
  WHERE
    ce.itemid IN (227290, 224146, 224149, 224144, 228004, 225183, 225977, 224154, 224151, 224150, 225958, 224145, 224191, 228005, 228006, 225976, 224153, 224152, 226457)
    AND NOT ce.value IS NULL
)
SELECT
  stay_id,
  charttime,
  MAX(crrt_mode) AS crrt_mode,
  MAX(accesspressure) AS access_pressure,
  MAX(bloodflow) AS blood_flow,
  MAX(citrate) AS citrate,
  MAX(currentgoal) AS current_goal,
  MAX(dialysatefluid) AS dialysate_fluid,
  MAX(dialysaterate) AS dialysate_rate,
  MAX(effluentpressure) AS effluent_pressure,
  MAX(filterpressure) AS filter_pressure,
  MAX(heparinconcentration) AS heparin_concentration,
  MAX(heparindose) AS heparin_dose,
  MAX(hourlypatientfluidremoval) AS hourly_patient_fluid_removal,
  MAX(prefilterreplacementrate) AS prefilter_replacement_rate,
  MAX(postfilterreplacementrate) AS postfilter_replacement_rate,
  MAX(replacementfluid) AS replacement_fluid,
  MAX(replacementrate) AS replacement_rate,
  MAX(returnpressure) AS return_pressure,
  MAX(ultrafiltrateoutput) AS ultrafiltrate_output,
  MAX(system_active) AS system_active,
  MAX(clots) AS clots,
  MAX(clots_increasing) AS clots_increasing,
  MAX(clotted) AS clotted
FROM crrt_settings
GROUP BY
  stay_id,
  charttime