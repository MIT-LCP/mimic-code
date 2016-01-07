--retrieves a glucose histogram of adult patients 

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

select bucket, count(*) from (
  select width_bucket(valuenum, 0.5, 1000, 1000) as bucket
    from mimiciii.labevents le
    inner join agetbl 
    on le.subject_id = agetbl.subject_id
   where itemid in (50809,50931) and valuenum is not null
       ) as glucose
        group by bucket order by bucket;
