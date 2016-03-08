-- --------------------------------------------------------
-- Title: Find the amount of bilirubin for adult patients 
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
    ((extract(DAY from ad.admittime - p.dob) 
		+ extract(HOUR from ad.admittime - p.dob) / 24
		+ extract(MINUTE from ad.admittime - p.dob) / 24 / 60
		) / 365.25 ) > 15
)
select bucket, count(*) from (
    select width_bucket(valuenum, 0, 280, 280) as bucket
    from mimiciii.labevents le
    inner join agetbl 
    on le.subject_id = agetbl.subject_id
    where itemid in (51006)) as bun
group by bucket 
order by bucket;
