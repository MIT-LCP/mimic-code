-- retrieves the urine output of adult patients 
-- only for patients recorded on carevue

with agetbl as
(
	select ad.subject_id, ad.hadm_id
       from mimiciii.admissions ad
       inner join mimiciii.patients p
       on ad.subject_id = p.subject_id 
       where
       -- filter to only adults
        ( 
		(extract(DAY from ad.admittime - p.dob) 
			+ extract(HOUR from ad.admittime - p.dob) /24
			+ extract(MINUTE from ad.admittime - p.dob) / 24 / 60
			) / 365.25 
	) > 15
)

select bucket*5, count(*) from (
  select width_bucket(volume, 0, 1000, 200) as bucket
    from mimiciii.ioevents ie
     inner join agetbl 
     on ie.subject_id = agetbl.subject_id
   where itemid in (55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405, 428, 
   473, 651, 715, 1922, 2042, 2068, 2111, 2119, 2130, 2366, 2463, 2507, 
   2510, 2592, 2676, 2810, 2859, 3053, 3175, 3462, 3519, 3966, 3987, 
   4132, 4253, 5927)
  ) as urine_output
  group by bucket order by bucket;

