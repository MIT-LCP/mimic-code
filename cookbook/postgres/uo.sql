-- --------------------------------------------------------
-- Title: Retrieves the urine output of adult patients 
--        only for patients recorded on carevue
-- MIMIC version: ?
-- --------------------------------------------------------

WITH agetbl AS
(
	SELECT ad.subject_id, ad.hadm_id
       FROM mimiciii.admissions ad
       INNER JOIN mimiciii.patients p
       ON ad.subject_id = p.subject_id 
       WHERE
       -- filter to only adults
        ( 
		(extract(DAY FROM ad.admittime - p.dob) 
			+ extract(HOUR FROM ad.admittime - p.dob) / 24
			+ extract(MINUTE FROM ad.admittime - p.dob) / 24 / 60
			) / 365.25 
	) > 15
)

SELECT bucket*5, COUNT(*) FROM (
  SELECT width_bucket(volume, 0, 1000, 200) AS bucket
    FROM mimiciii.ioevents ie
     INNER JOIN agetbl 
     ON ie.subject_id = agetbl.subject_id
   WHERE itemid IN (55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405, 428, 
   473, 651, 715, 1922, 2042, 2068, 2111, 2119, 2130, 2366, 2463, 2507, 
   2510, 2592, 2676, 2810, 2859, 3053, 3175, 3462, 3519, 3966, 3987, 
   4132, 4253, 5927)
  ) AS urine_output
  GROUP BY bucket 
  ORDER BY bucket;

