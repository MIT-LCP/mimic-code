-- retrieves the white blood cell count of adult patients 

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
  select width_bucket(valuenum, 0, 100, 1001) as bucket
    from mimiciii.labevents le
    inner join agetbl
    on le.subject_id = agetbl.subject_id
   where itemid in (51300, 51301) and valuenum is not null
       ) as white_blood_cell_count 
       group by bucket order by bucket;
