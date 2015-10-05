-- retrieves the temperature of adult patients 
-- only for patients recorded with carevue 

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

select (bucket/10) + 30, count(*) from (
  select width_bucket(
      case when itemid in (223762, 676) then valuenum -- celsius
           when itemid in (223761, 678) then (valuenum - 32) * 5 / 9 --fahrenheit 
           end, 30, 45, 160) as bucket
    from mimiciii.chartevents ce
    inner join agetbl 
    on ce.subject_id = agetbl.subject_id
    where itemid in (676, 677, 678, 679)
    )as temperature 
    group by bucket order by bucket;
