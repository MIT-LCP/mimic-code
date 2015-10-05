--retrieves the blood pressure of hospital survivors 
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

select bucket, count(*) from (
  select width_bucket(min_sbp, 0, 300, 300) as bucket from (
    select p.subject_id, ce.icustay_id, min(valuenum) as min_sbp
      from mimiciii.chartevents ce
      inner join agetbl 
      on ce.subject_id = agetbl.subject_id
      inner join mimiciii.patients p 
      on p.hospital_expire_flag = 'N'
     where itemid in (6, 51, 455, 6701)
       group by p.subject_id, ce.icustay_id
    ) as min_surviving_bp
  )as min_surviving_bp_counted
  group by bucket order by bucket;

