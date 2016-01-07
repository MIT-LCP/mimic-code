-- retrieves a height histogram of patients 

select bucket, count(*) 
from (
    select valuenum, width_bucket(valuenum, 1, 200, 200) as bucket 
    from mimiciii.chartevents 
    where itemid = 920 
    and valuenum is
    not null and valuenum > 0 and valuenum < 500
    ) as height 
group by bucket 
order by bucket;
