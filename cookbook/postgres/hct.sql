-- retrieves the hematocrit levels of adult patients 
-- only for patients recorded in carevue 

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
  select width_bucket(valuenum, 0, 150, 150) as bucket
    from mimiciii.chartevents ce
    inner join agetbl 
    on ce.subject_id = agetbl.subject_id
   where itemid in (813)
       ) as hct
      group by bucket order by bucket;

