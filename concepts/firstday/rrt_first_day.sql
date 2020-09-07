-- determines if patients received any dialysis during their stay

-- Some example aggregate queries which summarize the data here..
-- This query estimates 6.7% of ICU patients received RRT.
	-- select count(rrt.stay_id) as numobs
	-- , sum(rrt) as numrrt
	-- , sum(case when rrt=1 THEN 1 else 0 end)*100.0 / count(rrt.stay_id)
	-- as percent_rrt
	-- from rrt
	-- inner join icustays ie on rrt.stay_id = ie.stay_id
	-- inner join patients p
	-- on rrt.subject_id = p.subject_id
	-- AND p.dob < ie.intime - interval '1' year
	-- inner join admissions adm
	-- on rrt.hadm_id = adm.hadm_id;

-- This query estimates that 4.6% of first ICU stays received RRT.
	-- select
	--   count(rrt.stay_id) as numobs
	--   , sum(rrt) as numrrt
	--   , sum(case when rrt=1 THEN 1 else 0 end)*100.0 / count(rrt.stay_id)
	-- as percent_rrt
	-- from
	-- (
	-- select ie.stay_id, rrt.rrt
	--   , ROW_NUMBER() over (partition by ie.subject_id order by ie.intime) rn
	-- from rrt
	-- inner join icustays ie
	--   on rrt.stay_id = ie.stay_id
	-- inner join patients p
	--   on rrt.subject_id = p.subject_id
	-- AND p.dob < ie.intime - interval '1' year
	-- inner join admissions adm
	--   on rrt.hadm_id = adm.hadm_id
	-- ) rrt
	-- where rn = 1;

WITH ce AS (
	SELECT
		ie.stay_id
		, 1 as RRT
	FROM `physionet-data.mimic_icu.icustays` ie
	INNER JOIN `physionet-data.mimic_icu.chartevents` ce ON
		ie.stay_id = ce.stay_id
		AND ce.charttime BETWEEN ie.intime AND DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
		AND itemid IN (
			-- Checkboxes
			226118 -- | Dialysis Catheter placed in outside facility      | Access Lines - Invasive | chartevents        | Checkbox
			, 227357 -- | Dialysis Catheter Dressing Occlusive              | Access Lines - Invasive | chartevents        | Checkbox
			, 225725 -- | Dialysis Catheter Tip Cultured                    | Access Lines - Invasive | chartevents        | Checkbox
			-- Numeric values
			, 226499 -- | Hemodialysis Output                               | Dialysis                | chartevents        | Numeric
			, 224154 -- | Dialysate Rate                                    | Dialysis                | chartevents        | Numeric
			, 225810 -- | Dwell Time (Peritoneal Dialysis)                  | Dialysis                | chartevents        | Numeric
			, 227639 -- | Medication Added Amount  #2 (Peritoneal Dialysis) | Dialysis                | chartevents        | Numeric
			, 225183 -- | Current Goal                     | Dialysis | chartevents        | Numeric
			, 227438 -- | Volume not removed               | Dialysis | chartevents        | Numeric
			, 224191 -- | Hourly Patient Fluid Removal     | Dialysis | chartevents        | Numeric
			, 225806 -- | Volume In (PD)                   | Dialysis | chartevents        | Numeric
			, 225807 -- | Volume Out (PD)                  | Dialysis | chartevents        | Numeric
			, 228004 -- | Citrate (ACD-A)                  | Dialysis | chartevents        | Numeric
			, 228005 -- | PBP (Prefilter) Replacement Rate | Dialysis | chartevents        | Numeric
			, 228006 -- | Post Filter Replacement Rate     | Dialysis | chartevents        | Numeric
			, 224144 -- | Blood Flow (ml/min)              | Dialysis | chartevents        | Numeric
			, 224145 -- | Heparin Dose (per hour)          | Dialysis | chartevents        | Numeric
			, 224149 -- | Access Pressure                  | Dialysis | chartevents        | Numeric
			, 224150 -- | Filter Pressure                  | Dialysis | chartevents        | Numeric
			, 224151 -- | Effluent Pressure                | Dialysis | chartevents        | Numeric
			, 224152 -- | Return Pressure                  | Dialysis | chartevents        | Numeric
			, 224153 -- | Replacement Rate                 | Dialysis | chartevents        | Numeric
			, 224404 -- | ART Lumen Volume                 | Dialysis | chartevents        | Numeric
			, 224406 -- | VEN Lumen Volume                 | Dialysis | chartevents        | Numeric
			, 226457 -- | Ultrafiltrate Output             | Dialysis | chartevents        | Numeric
		)
	AND valuenum > 0 -- also ensures it's not null
	GROUP BY ie.stay_id
), ie AS (
	select
		ie.stay_id
		, 1 as RRT
	FROM `physionet-data.mimic_icu.icustays` ie
	INNER JOIN `physionet-data.mimic_icu.inputevents` tt ON
		ie.stay_id = tt.stay_id
		AND tt.starttime BETWEEN ie.intime AND DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
		AND itemid in (
			227536 --	KCl (CRRT)	Medications	inputevents_mv	Solution
			, 227525 --	Calcium Gluconate (CRRT)	Medications	inputevents_mv	Solution
		)
		AND amount > 0 -- also ensures it's not null
	GROUP BY ie.stay_id
), de AS (
  SELECT
  	ie.stay_id
	, 1 as RRT
  FROM `physionet-data.mimic_icu.icustays` ie
  INNER JOIN `physionet-data.mimic_icu.datetimeevents` tt ON
	ie.stay_id = tt.stay_id
	AND tt.charttime BETWEEN ie.intime AND DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
	AND itemid IN
	(
	  -- TODO: unsure how to handle "Last dialysis"
	  --  225128 -- | Last dialysis                                     | Adm History/FHPA        | datetimeevents     | Date time
		225318 -- | Dialysis Catheter Cap Change                      | Access Lines - Invasive | datetimeevents     | Date time
	  , 225319 -- | Dialysis Catheter Change over Wire Date           | Access Lines - Invasive | datetimeevents     | Date time
	  , 225321 -- | Dialysis Catheter Dressing Change                 | Access Lines - Invasive | datetimeevents     | Date time
	  , 225322 -- | Dialysis Catheter Insertion Date                  | Access Lines - Invasive | datetimeevents     | Date time
	  , 225324 -- | Dialysis CatheterTubing Change                    | Access Lines - Invasive | datetimeevents     | Date time
	)
  GROUP BY ie.stay_id
), pe as (
	SELECT
		ie.stay_id
		, 1 as RRT
	FROM `physionet-data.mimic_icu.icustays` ie
	inner join `physionet-data.mimic_icu.procedureevents` tt ON
	  ie.stay_id = tt.stay_id
	  AND tt.starttime BETWEEN ie.intime AND DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
	  AND itemid in
	  (
		  225441 -- | Hemodialysis                                      | 4-Procedures            | procedureevents_mv | Process
		, 225802 -- | Dialysis - CRRT                                   | Dialysis                | procedureevents_mv | Process
		, 225803 -- | Dialysis - CVVHD                                  | Dialysis                | procedureevents_mv | Process
		, 225805 -- | Peritoneal Dialysis                               | Dialysis                | procedureevents_mv | Process
		, 224270 -- | Dialysis Catheter                                 | Access Lines - Invasive | procedureevents_mv | Process
		, 225809 -- | Dialysis - CVVHDF                                 | Dialysis                | procedureevents_mv | Process
		, 225955 -- | Dialysis - SCUF                                   | Dialysis                | procedureevents_mv | Process
		, 225436 -- | CRRT Filter Change               | Dialysis | procedureevents_mv | Process
	  )
	GROUP BY ie.stay_id
)
select
	icustays.subject_id
	, icustays.hadm_id
	, icustays.stay_id
	, CASE
		WHEN ce.RRT = 1 THEN 1
		WHEN ie.RRT = 1 THEN 1
		WHEN de.RRT = 1 THEN 1
		WHEN pe.RRT = 1 THEN 1
		ELSE 0 end as rrt
FROM `physionet-data.mimic_icu.icustays` icustays
LEFT JOIN ce USING (stay_id)
LEFT JOIN ie USING(stay_id)
LEFT JOIN de USING(stay_id)
LEFT JOIN pe USING(stay_id)
ORDER BY icustays.stay_id;
