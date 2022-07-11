-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS rhythm; CREATE TABLE rhythm AS 
-- Heart rhythm related documentation
select 
    ce.subject_id
  , ce.charttime
  , MAX(case when itemid = 220048 THEN value ELSE NULL END) AS heart_rhythm
  , MAX(case when itemid = 224650 THEN value ELSE NULL END) AS ectopy_type
  , MAX(case when itemid = 224651 THEN value ELSE NULL END) AS ectopy_frequency
  , MAX(case when itemid = 226479 THEN value ELSE NULL END) AS ectopy_type_secondary
  , MAX(case when itemid = 226480 THEN value ELSE NULL END) AS ectopy_frequency_secondary
FROM mimiciv_icu.chartevents ce
where ce.stay_id IS NOT NULL
and ce.itemid in
(
220048, -- Heart Rhythm
224650, -- Ectopy Type 1
224651, -- Ectopy Frequency 1
226479, -- Ectopy Type 2
226480  -- Ectopy Frequency 2
)
GROUP BY ce.subject_id, ce.charttime
;
