# Postgres 10

Postgres 9.6 introduced parallel querying, and postgres 10 refines it. Let's test it out.

CPU: Intel Core i7-2600K CPU @ 3.40GHz x 8
Memory: 8 GB
OS: Ubuntu 16.04 64-bit

```sql
EXPLAIN ANALYZE select
  ie.icustay_id
  , min(case when itemid = 211 then valuenum else null end) as HeartRate_Min
  , max(case when itemid = 211 then valuenum else null end) as HeartRate_Max
  , min(case when itemid in (615,618) then valuenum else null end) as RespRate_Min
  , max(case when itemid in (615,618) then valuenum else null end) as RespRate_Max
from icustays ie
-- join to the chartevents table to get the observations
left join chartevents ce
  -- match the tables on the patient identifier
  on ie.icustay_id = ce.icustay_id
  and ce.charttime >= ie.intime and ce.charttime <= ie.intime + interval '1' day
  and ce.itemid in (211,615,618)
group by ie.icustay_id
order by ie.icustay_id;
```

```
QUERY PLAN                                                                       
--------------------------------------------------------------------------------------------------------------------------------------------------------
GroupAggregate  (cost=552231.10..577797.87 rows=61532 width=36) (actual time=5149.385..5843.356 rows=61532 loops=1)
Group Key: ie.icustay_id
->  Sort  (cost=552231.10..554726.25 rows=998058 width=16) (actual time=5149.377..5331.140 rows=1848373 loops=1)
Sort Key: ie.icustay_id
Sort Method: external merge  Disk: 46792kB
->  Hash Right Join  (cost=2102.47..435721.79 rows=998058 width=16) (actual time=34.560..4579.763 rows=1848373 loops=1)
Hash Cond: (ce.icustay_id = ie.icustay_id)
Join Filter: ((ce.charttime >= ie.intime) AND (ce.charttime <= (ie.intime + '1 day'::interval day)))
Rows Removed by Join Filter: 7152657
->  Append  (cost=0.00..252846.25 rows=8982526 width=24) (actual time=0.037..2350.058 rows=8984577 loops=1)
->  Seq Scan on chartevents_31 ce  (cost=0.00..140305.86 rows=5180790 width=24) (actual time=0.037..1021.600 rows=5180809 loops=1)
Filter: (itemid = ANY ('{211,615,618}'::integer[]))
->  Seq Scan on chartevents_60 ce_1  (cost=0.00..20819.96 rows=415014 width=24) (actual time=0.015..127.552 rows=417049 loops=1)
Filter: (itemid = ANY ('{211,615,618}'::integer[]))
Rows Removed by Filter: 357857
->  Seq Scan on chartevents_62 ce_2  (cost=0.00..91720.43 rows=3386722 width=24) (actual time=0.014..686.985 rows=3386719 loops=1)
Filter: (itemid = ANY ('{211,615,618}'::integer[]))
->  Hash  (cost=1333.32..1333.32 rows=61532 width=12) (actual time=34.429..34.429 rows=61532 loops=1)
Buckets: 65536  Batches: 1  Memory Usage: 3397kB
->  Seq Scan on icustays ie  (cost=0.00..1333.32 rows=61532 width=12) (actual time=0.016..19.119 rows=61532 loops=1)
Planning time: 10.334 ms
Execution time: 5851.323 ms
(22 rows)
```

Here we notice that we are doing sequential scans on three partitions of chartevents, and the query takes about 5.8 seconds.

In order to use parallel sequential scans, we need to have a where clause, so let's introduce that here.

```sql
EXPLAIN ANALYZE select
  ie.icustay_id
  , min(case when itemid = 211 then valuenum else null end) as HeartRate_Min
  , max(case when itemid = 211 then valuenum else null end) as HeartRate_Max
  , min(case when itemid in (615,618) then valuenum else null end) as RespRate_Min
  , max(case when itemid in (615,618) then valuenum else null end) as RespRate_Max
from icustays ie
-- join to the chartevents table to get the observations
left join chartevents ce
  -- match the tables on the patient identifier
  on ie.icustay_id = ce.icustay_id
  and ce.itemid in (211,615,618)                                                
WHERE ce.charttime >= ie.intime and ce.charttime <= ie.intime + interval '1' day
group by ie.icustay_id
order by ie.icustay_id;
```

```
QUERY PLAN                                                                                  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Finalize GroupAggregate  (cost=302256.82..329626.85 rows=61532 width=36) (actual time=1986.926..2326.192 rows=35724 loops=1)
Group Key: ie.icustay_id
->  Gather Merge  (cost=302256.82..327473.23 rows=123064 width=36) (actual time=1986.908..2300.455 rows=101637 loops=1)
Workers Planned: 2
Workers Launched: 2
->  Partial GroupAggregate  (cost=301256.79..312268.56 rows=61532 width=36) (actual time=1977.141..2261.446 rows=33879 loops=3)
Group Key: ie.icustay_id
->  Sort  (cost=301256.79..302296.44 rows=415858 width=16) (actual time=1977.113..2057.813 rows=607522 loops=3)
Sort Key: ie.icustay_id
Sort Method: external merge  Disk: 15728kB
->  Hash Join  (cost=2102.47..255336.82 rows=415858 width=16) (actual time=34.577..1752.769 rows=607522 loops=3)
Hash Cond: (ce.icustay_id = ie.icustay_id)
Join Filter: ((ce.charttime >= ie.intime) AND (ce.charttime <= (ie.intime + '1 day'::interval day)))
Rows Removed by Join Filter: 2384219
->  Append  (cost=0.00..177912.27 rows=3742718 width=24) (actual time=0.037..893.004 rows=2994859 loops=3)
->  Parallel Seq Scan on chartevents_31 ce  (cost=0.00..98751.61 rows=2158662 width=24) (actual time=0.036..409.982 rows=1726936 loops=3)
Filter: (itemid = ANY ('{211,615,618}'::integer[]))
->  Parallel Seq Scan on chartevents_60 ce_1  (cost=0.00..14604.57 rows=172922 width=24) (actual time=0.026..46.224 rows=139016 loops=3)
Filter: (itemid = ANY ('{211,615,618}'::integer[]))
Rows Removed by Filter: 119286
->  Parallel Seq Scan on chartevents_62 ce_2  (cost=0.00..64556.09 rows=1411134 width=24) (actual time=0.024..247.441 rows=1128906 loops=3)
Filter: (itemid = ANY ('{211,615,618}'::integer[]))
->  Hash  (cost=1333.32..1333.32 rows=61532 width=12) (actual time=34.310..34.310 rows=61532 loops=3)
Buckets: 65536  Batches: 1  Memory Usage: 3397kB
->  Seq Scan on icustays ie  (cost=0.00..1333.32 rows=61532 width=12) (actual time=0.017..18.052 rows=61532 loops=3)
Planning time: 10.214 ms
Execution time: 2332.014 ms
(27 rows)
```

Pretty good! Query time halved from 5.8 seconds to 2.3 seconds.
