-- retrieves the blood serum potassium levels of adult patients

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

select bucket/10, count(*) from (
  select width_bucket(valuenum, 0, 10, 100) as bucket
    from mimiciii.labevents le
    inner join agetbl
    on le.subject_id = agetbl.subject_id
   where itemid in (50822, 50971)
       )as potassium
       group by bucket order by bucket;
