-- ------------------------------------------------------------------
-- This file creates a septic cohort regarding a definition of Sepsis
-- -that says two SIRS criteria should be met as well as a blood culture ordered-
-- Then aggregates some features such as survival statues, Charlson index,
-- sofa at day 1,3,5,7 and some demographic data
-- ------------------------------------------------------------------

--The cohort is created according to the following criteria:
--Patients were included
-- (1) if they were aged 18 years or older
-- and (2) met 2 out of 4 systemic inflammatory response syndrome (SIRS) criteria within 4 hours of each other 
-- and (3) had a blood culture ordered, all within 24 hours,
-- and (4) they were admitted to the ICU for at least 48 hours during hospital admission.
-- (Hospital admission was defined as the time an admission order was placed in the ED).
-- Patients were excluded for any of the following:
-- (1) they were transferred FROM an outside hospital; 
-- (2) they were not admitted through the emergency department, or that information was unknown;
-- or (3) they were admitted to the ICU greater than 72 hours FROM ED presentation. Patients were followed until death,
-- ICU discharge, or for the first 7 days of ICU stay, whichever came first. 
-- Those who were admitted to an ICU more than once in a single hospital admission only had their first ICU encounter included in the study.

--creates the cohort. One condition still remains (2 out of 4 SIRS criteria components should be met). So it's not the final cohort
CREATE VIEW a_patient_cohort AS
SELECT count (*) FROM (SELECT DISTINCT ON (subject_id) i.subject_id, i.hadm_id, i.icustay_id, i.intime, i.outtime, a.admittime, a.dischtime, a.deathtime
FROM admissions a, icustay_detail i
WHERE a.hadm_id = i.hadm_id AND a.admission_location::text = 'EMERGENCY ROOM ADMIT'::text 
AND i.age >= 18::numeric AND i.icustay_seq = 1 AND i.intime - a.admittime < '72:00:00'::interval 
AND i.intime > a.admittime AND i.outtime - i.intime >= '48:00:00'::interval 
ORDER BY subject_id, admittime) as foo;

--fetches the time of blood culture orders
CREATE VIEW a_blood_culture_ordered AS
SELECT pc.hadm_id,pc.icustay_id,pc.intime,m.charttime AS bloodCulture_time 
FROM a_patient_cohort  pc, microbiologyevents m
WHERE pc.hadm_id = m.hadm_id AND m.spec_itemid = 70012 AND m.charttime < pc.intime + interval '24 hours';

--fetches white blood cell counts
CREATE VIEW a_wbcc AS 
SELECT L.hadm_id, charttime, valuenum,intime
FROM labevents L, a_patient_cohort  pc WHERE L.hadm_id = pc.hadm_id AND itemid = 51301 
AND l.charttime < pc.intime + interval '24 hours' AND l.charttime + interval '4 hours' > pc.intime;

--fetches respiratory rate
CREATE VIEW a_rr AS 
SELECT p.hadm_id, charttime, valuenum,intime
FROM chartevents C, a_patient_cohort  p
WHERE itemid IN (618,220210) AND C.hadm_id = p.hadm_id AND charttime < intime + interval '24 hours'
AND  charttime > intime - interval '4 hours' AND valuenum != 0;

--fetches heart rate
CREATE VIEW a_hr AS 
SELECT p.hadm_id, charttime, valuenum, intime
FROM chartevents C, a_patient_cohort  p
WHERE itemid IN (211,220045) AND C.hadm_id = p.hadm_id AND charttime < intime + interval '24 hours'
AND  charttime > intime - interval '4 hours' AND valuenum != 0;

--fetches temperature
CREATE TABLE a_temp1 AS
SELECT C.hadm_id, charttime, valuenum, intime
FROM chartevents C, a_patient_cohort  pc WHERE itemid IN (676,677,223762)
AND c.hadm_id = pc.hadm_id AND charttime < intime + interval '24 hours' AND intime - interval '4 hours' < charttime AND valuenum > 20 
UNION
SELECT C.hadm_id, charttime, (((valuenum)-32)*5/9)::float AS valuenum, intime
FROM chartevents C, a_patient_cohort  pc WHERE itemid IN (678,679,223761)
AND c.hadm_id = pc.hadm_id AND charttime < intime + interval '24 hours' AND intime - interval '4 hours' < charttime AND valuenum > 20 
UNION
SELECT L.hadm_id, charttime, valuenum, intime 
FROM labevents L, a_patient_cohort  pc WHERE itemid = 50825
AND L.hadm_id = pc.hadm_id AND charttime < intime + interval '24 hours' AND intime - interval '4 hours' < charttime AND valuenum > 20; 

--gathers all 4 SIRS components together: heart rate, respiratory rate, temperature, white blood cell counts
CREATE TABLE a_sirs AS
SELECT * FROM (
SELECT hadm_id,max(valuenum), 1 as typ--'temp'
,datediff('minute', intime, charttime) AS minutes
FROM a_temp1
GROUP BY hadm_id,minutes
UNION
SELECT hadm_id,max(valuenum), 2 as typ --'rr1'
,datediff('minute', intime, charttime) AS minutes
FROM a_rr
GROUP BY hadm_id,minutes
UNION
SELECT hadm_id,max(valuenum), 3 as typ --'hr'
,datediff('minute', intime, charttime) AS minutes
FROM a_hr
GROUP BY hadm_id,minutes
UNION
SELECT hadm_id,max(valuenum), 4 as typ --'wbc1'
,datediff('minute', intime, charttime) AS minutes
FROM a_wbcc
GROUP BY hadm_id,minutes
) AS foo
ORDER BY hadm_id,minutes;

-- The fact that SIRS criteria has been met is verified in MATLAB, then the results has been put in a_has_sirs table
--includes only patients who have met SIRS criteria
CREATE TABLE a_has_sirs --8006:0  1142:1
(
HADM_ID INT NOT NULL,
constraint sirs_hadmid primary key (HADM_ID)
);

--Someone has Sepsis if she meets the SIRS criteria and has a blood culture ordered 
create view a_has_sepsis as
SELECT distinct on (hadm_id) b.hadm_id
FROM a_has_sirs s 
inner join a_blood_culture_ordered b on s.hadm_id = b.hadm_id 
order by hadm_id;

--This is the final cohort we are going to work with
CREATE Table a_cohort AS
SELECT * FROM a_patient_cohort  pc1
WHERE pc1.hadm_id IN (SELECT hadm_id FROM a_has_sepsis);

-- gets avg and max sofa 
CREATE VIEW a_sofa_max_mean as
SELECT icustay_id, max(sofa) as sofa_max, round(avg(sofa),0) as sofa_mean 
FROM a_sofa
WHERE dailyInterval IN (0,2,4,6)
and icustay_id in (SELECT icustay_id FROM a_cohort)
group by icustay_id;

--chooses sofa score in day 1,3,7 (We only need these days)
CREATE VIEW a_multiple_sofa AS
SELECT s1.icustay_id, 
s1.sofa as sofa_day1, s3.sofa as sofa_day3, s5.sofa as sofa_day5, s7.sofa as sofa_day7
FROM a_sofa s1
left join a_sofa s3 on s1.icustay_id = s3.icustay_id AND s3.dailyInterval = 2 
left join a_sofa s5 on s1.icustay_id = s5.icustay_id AND s5.dailyInterval = 4
left join a_sofa s7 on s1.icustay_id = s7.icustay_id AND s7.dailyInterval = 6
WHERE s1.dailyInterval = 0;

--filters patients who have sepsis by choosing them FROM the main cohort
CREATE TABLE a_sofa_cohort as
SELECT * FROM a_multiple_sofa
WHERE icustay_id in (SELECT icustay_id FROM a_cohort);

--estimates ventilator duration. It uses VENTILATION_DURATION.SQL FROM github (which we used for calculating sofa)
CREATE VIEW a_venttime AS
SELECT icustay_id, 
sum(datediff('hour',starttime,endtime))/24 as vent_duration --how many days
FROM ventdurations
WHERE icustay_id is not null
group by icustay_id;

--calculates max amount of heart rate in first 24 hours
create view a_max_hr as
SELECT hadm_id, max(valuenum) FROM a_hr
group by hadm_id;

--calculates max amount of respiratory rate in first 24 hours of ICU
create view a_max_rr as
SELECT hadm_id, max(valuenum) FROM a_rr
group by hadm_id;

--determines if someone has an abnormal temperature value in first 24 hours of ICU
create view a_abnormal_tmp as
SELECT hadm_id, max(abnormality) as abnormal_temp FROM 
	(SELECT hadm_id,
	CASE
		WHEN valuenum > 38 or valuenum < 36 then 1
		ELSE 0
	END as abnormality
	FROM a_temp1
	) as foo
group by hadm_id;

--determines if someone has an abnormal white blood cell count in first 24 hours of ICU
create view a_abnormal_wbc as
SELECT hadm_id, max(abnormality) as abnormal_wbc FROM 
	(SELECT hadm_id,
	CASE
		WHEN valuenum > 12 or valuenum < 4 then 1
		ELSE 0
	END as abnormality
	FROM a_wbcc
	) as foo
group by hadm_id;

-- aggregates all attributes for each patient
CREATE TABLE a_final_data AS
SELECT c.subject_id, c.hadm_id, c.icustay_id,
a.ethnicity,
CASE 
	WHEN lower(a.ethnicity) similar to '%white%' then 'WHITE'
	WHEN lower(a.ethnicity) similar to '%black%' then 'BLACK'
	ELSE 'OTHER'
END as grouped_ethnicity,
i.gender,
CASE WHEN i.age >89 THEN 89 ELSE floor(i.age) END AS age,
ch.cci,
ii.first_careunit,
s.sofa_day1, s.sofa_day3, s.sofa_day5, s.sofa_day7,
sm.sofa_max, sm.sofa_mean,
tm.abnormal_temp,
wb.abnormal_wbc,
hr.max as max_hr,
rr.max as max_rr,
CASE WHEN v.vent_duration is null then 0 ELSE v.vent_duration END as vent_duration,
datediff('hour',a.admittime,a.dischtime)/24 as hospital_duration,
datediff('hour',ii.intime,ii.outtime)/24 as icu_duration,
CASE
	WHEN a.deathtime is null then 1 
	ELSE 0 
END as survivor
FROM a_cohort c
LEFT JOIN admissions a on c.hadm_id = a.hadm_id
LEFT JOIN icustay_detail i on c.icustay_id = i.icustay_id
LEFT JOIN a_Charlson_Index ch on c.hadm_id = ch.hadm_id 
LEFT JOIN icustays ii on c.icustay_id = ii.icustay_id	 
LEFT JOIN a_sofa_cohort s on c.icustay_id = s.icustay_id
LEFT JOIN a_sofa_max_mean sm on c.icustay_id = sm.icustay_id	
LEFT JOIN a_venttime v on c.icustay_id = v.icustay_id
LEFT JOIN a_abnormal_tmp tm on c.hadm_id = tm.hadm_id
LEFT JOIN a_abnormal_wbc wb on c.hadm_id = wb.hadm_id
LEFT JOIN a_max_hr hr on c.hadm_id = hr.hadm_id
LEFT JOIN a_max_rr rr on c.hadm_id = rr.hadm_id
;