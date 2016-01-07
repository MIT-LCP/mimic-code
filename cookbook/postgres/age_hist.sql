-- This query counts the number of ages in equally sized bins of 1 year

with agetbl as
(
    select (extract(DAY from ad.admittime - p.dob) 
            + extract(HOUR from ad.admittime - p.dob) / 24
            + extract(MINUTE from ad.admittime - p.dob) / 24 / 60
            ) / 365.25
            as age
      from MIMICIII.admissions ad
      inner join MIMICIII.patients p
      on ad.subject_id = p.subject_id 
)
, agebin as
(
      select age, width_bucket(age, 15, 100, 85) as bucket 
      from agetbl
)
select bucket+15, count(*) 
from agebin
group by bucket 
order by bucket;