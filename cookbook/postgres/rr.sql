-- --------------------------------------------------------
-- Title: Retrieves the respiration rate of adult patients 
--        only for patients recorded with carevue 
-- MIMIC version: ?
-- --------------------------------------------------------

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
  select valuenum, width_bucket(valuenum, 0, 130, 1400) as bucket
    from mimiciii.chartevents ce
    inner join agetbl
    on ce.subject_id = agetbl.subject_id
    where itemid in (219, 615, 618)
       ) as respiration_rate
        group by bucket 
        order by bucket;
