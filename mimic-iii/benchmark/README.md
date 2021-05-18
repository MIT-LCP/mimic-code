# Execution times

## postgres-benchmark-1

### Without any indexes/partitions:

```
Execution time: 27979.436 ms
```

### Create a clustered index on chartevents

Clustering physically orders the data according to the index. It can speed up queries by reducing the number of page seeks required.
Fill factor specifies how much space to physically use - 99% indicates there is almost no free space leftover. This is desirable as this is a static database with no inserts. Lower fill factors would not only waste space but also force postgres to spend extra time scanning over empty space.

```sql
CREATE INDEX CHARTEVENTS_idxTest01
  ON CHARTEVENTS
  USING btree
  (ICUSTAY_ID, CHARTTIME, ITEMID, VALUENUM)
  WITH (FILLFACTOR=99);
ALTER TABLE CHARTEVENTS CLUSTER ON member_name_idx;

-- note we do this to update the planner statistics information.
-- It's important since this information helps the planner at selecting indexes and scan approach.
ANALYZE CHARTEVENTS;
```

Benchmark:

```
Execution time: 26973.926 ms
```

No real difference. Let's try adding an index on ICUSTAYS.

### Index on ICUSTAY_ID and INTIME

```SQL
drop index IF EXISTS ICUSTAYS_idx07;
CREATE INDEX ICUSTAYS_idx07
  ON ICUSTAYS (ICUSTAY_ID, INTIME);
```

Benchmark:


```
Execution time: 28051.395 ms
```

Slower! And still doing a sequence scan on ICUSTAY_ID.

## Detailed analysis plan - postgres-benchmark-1

```
QUERY PLAN                                                                               
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
GroupAggregate  (cost=4600766.03..4771752.91 rows=61532 width=16) (actual time=24931.820..27960.580 rows=61532 loops=1)
Group Key: ie.icustay_id
->  Merge Left Join  (cost=4600766.03..4700343.65 rows=5663515 width=16) (actual time=24931.807..26925.630 rows=5200851 loops=1)
Merge Cond: (ie.icustay_id = ce.icustay_id)
->  Sort  (cost=6227.90..6381.73 rows=61532 width=4) (actual time=88.562..101.166 rows=61532 loops=1)
Sort Key: ie.icustay_id
Sort Method: external merge  Disk: 840kB
->  Seq Scan on icustays ie  (cost=0.00..1333.32 rows=61532 width=4) (actual time=0.019..21.610 rows=61532 loops=1)
->  Materialize  (cost=4594535.48..4623180.56 rows=5729017 width=16) (actual time=24843.237..26207.168 rows=5176173 loops=1)
->  Sort  (cost=4594535.48..4608858.02 rows=5729017 width=16) (actual time=24843.233..25803.950 rows=5176173 loops=1)
Sort Key: ce.icustay_id
Sort Method: external merge  Disk: 152144kB
->  Bitmap Heap Scan on chartevents ce  (cost=107236.45..3755639.44 rows=5729017 width=16) (actual time=656.601..20416.119 rows=5190683 loops=1)
Recheck Cond: (itemid = 211)
Rows Removed by Index Recheck: 144652722
Heap Blocks: exact=31233 lossy=1974272
->  Bitmap Index Scan on chartevents_idx02  (cost=0.00..105804.20 rows=5729017 width=0) (actual time=651.418..651.418 rows=5190683 loops=1)
Index Cond: (itemid = 211)
Planning time: 0.595 ms
Execution time: 27979.436 ms
(20 rows)
```

With clustered index:

```
QUERY PLAN                                                                               
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
GroupAggregate  (cost=4591858.32..4760287.13 rows=61532 width=16) (actual time=23981.176..26954.225 rows=61532 loops=1)
Group Key: ie.icustay_id
->  Merge Left Join  (cost=4591858.32..4689943.20 rows=5578289 width=16) (actual time=23981.163..25910.845 rows=5200851 loops=1)
Merge Cond: (ie.icustay_id = ce.icustay_id)
->  Sort  (cost=6227.90..6381.73 rows=61532 width=4) (actual time=84.862..96.358 rows=61532 loops=1)
Sort Key: ie.icustay_id
Sort Method: external merge  Disk: 840kB
->  Seq Scan on icustays ie  (cost=0.00..1333.32 rows=61532 width=4) (actual time=0.018..19.140 rows=61532 loops=1)
->  Materialize  (cost=4585630.42..4613836.83 rows=5641283 width=16) (actual time=23896.294..25198.480 rows=5176173 loops=1)
->  Sort  (cost=4585630.42..4599733.63 rows=5641283 width=16) (actual time=23896.289..24806.948 rows=5176173 loops=1)
Sort Key: ce.icustay_id
Sort Method: external merge  Disk: 152144kB
->  Bitmap Heap Scan on chartevents ce  (cost=105592.51..3760206.45 rows=5641283 width=16) (actual time=654.503..19768.776 rows=5190683 loops=1)
Recheck Cond: (itemid = 211)
Rows Removed by Index Recheck: 144652722
Heap Blocks: exact=31233 lossy=1974272
->  Bitmap Index Scan on chartevents_idx02  (cost=0.00..104182.19 rows=5641283 width=0) (actual time=649.304..649.304 rows=5190683 loops=1)
Index Cond: (itemid = 211)
Planning time: 12.673 ms
Execution time: 26973.926 ms
(20 rows)
```

```
QUERY PLAN                                                                               
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
GroupAggregate  (cost=4579718.28..4744634.04 rows=61532 width=16) (actual time=24596.006..28032.285 rows=61532 loops=1)
Group Key: ie.icustay_id
->  Merge Left Join  (cost=4579718.28..4675757.38 rows=5460907 width=16) (actual time=24595.992..26859.053 rows=5200851 loops=1)
Merge Cond: (ie.icustay_id = ce.icustay_id)
->  Sort  (cost=6227.90..6381.73 rows=61532 width=4) (actual time=83.553..207.046 rows=61532 loops=1)
Sort Key: ie.icustay_id
Sort Method: external merge  Disk: 840kB
->  Seq Scan on icustays ie  (cost=0.00..1333.32 rows=61532 width=4) (actual time=0.011..16.905 rows=61532 loops=1)
->  Materialize  (cost=4573490.38..4601126.55 rows=5527234 width=16) (actual time=24512.432..25979.279 rows=5176173 loops=1)
->  Sort  (cost=4573490.38..4587308.47 rows=5527234 width=16) (actual time=24512.427..25554.097 rows=5176173 loops=1)
Sort Key: ce.icustay_id
Sort Method: external merge  Disk: 152144kB
->  Bitmap Heap Scan on chartevents ce  (cost=103460.63..3765568.96 rows=5527234 width=16) (actual time=661.343..20041.063 rows=5190683 loops=1)
Recheck Cond: (itemid = 211)
Rows Removed by Index Recheck: 144652722
Heap Blocks: exact=31233 lossy=1974272
->  Bitmap Index Scan on chartevents_idx02  (cost=0.00..102078.83 rows=5527234 width=0) (actual time=655.994..655.994 rows=5190683 loops=1)
Index Cond: (itemid = 211)
Planning time: 1.616 ms
Execution time: 28051.395 ms
```

## postgres-benchmark-2

Without any indexes/partitions:

```
Execution time: 23449.158 ms
```

### Clustered index on chartevents

```
Execution time: 22863.388 ms
```

### Index on ICUSTAYS

```
Execution time: 24007.923 ms
```

## Detailed analysis plan - postgres-benchmark-2

```
QUERY PLAN                                                                            
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
GroupAggregate  (cost=3999831.71..4009886.22 rows=61532 width=16) (actual time=23061.487..23444.792 rows=61532 loops=1)
Group Key: ie.icustay_id
->  Sort  (cost=3999831.71..4001404.91 rows=629279 width=16) (actual time=23061.476..23226.079 rows=975547 loops=1)
Sort Key: ie.icustay_id
Sort Method: external merge  Disk: 24440kB
->  Hash Right Join  (cost=109338.92..3928466.14 rows=629279 width=16) (actual time=744.683..22181.639 rows=975547 loops=1)
Hash Cond: (ce.icustay_id = ie.icustay_id)
Join Filter: ((ce.charttime >= ie.intime) AND (ce.charttime <= (ie.intime + '1 day'::interval day)))
Rows Removed by Join Filter: 4225921
->  Bitmap Heap Scan on chartevents ce  (cost=107236.45..3755639.44 rows=5729017 width=24) (actual time=696.385..19914.989 rows=5190683 loops=1)
Recheck Cond: (itemid = 211)
Rows Removed by Index Recheck: 144652722
Heap Blocks: exact=31233 lossy=1974272
->  Bitmap Index Scan on chartevents_idx02  (cost=0.00..105804.20 rows=5729017 width=0) (actual time=690.725..690.725 rows=5190683 loops=1)
Index Cond: (itemid = 211)
->  Hash  (cost=1333.32..1333.32 rows=61532 width=12) (actual time=48.247..48.247 rows=61532 loops=1)
Buckets: 8192  Batches: 1  Memory Usage: 2885kB
->  Seq Scan on icustays ie  (cost=0.00..1333.32 rows=61532 width=12) (actual time=0.020..28.346 rows=61532 loops=1)
Planning time: 0.644 ms
Execution time: 23449.158 ms
(20 rows)

```


```
QUERY PLAN                                                                            
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
GroupAggregate  (cost=4000669.79..4010582.26 rows=61532 width=16) (actual time=22484.026..22858.840 rows=61532 loops=1)
Group Key: ie.icustay_id
->  Sort  (cost=4000669.79..4002219.31 rows=619810 width=16) (actual time=22484.014..22642.114 rows=975547 loops=1)
Sort Key: ie.icustay_id
Sort Method: external merge  Disk: 24440kB
->  Hash Right Join  (cost=107694.98..3930445.02 rows=619810 width=16) (actual time=695.669..21656.540 rows=975547 loops=1)
Hash Cond: (ce.icustay_id = ie.icustay_id)
Join Filter: ((ce.charttime >= ie.intime) AND (ce.charttime <= (ie.intime + '1 day'::interval day)))
Rows Removed by Join Filter: 4225921
->  Bitmap Heap Scan on chartevents ce  (cost=105592.51..3760206.45 rows=5641283 width=24) (actual time=658.490..19481.675 rows=5190683 loops=1)
Recheck Cond: (itemid = 211)
Rows Removed by Index Recheck: 144652722
Heap Blocks: exact=31233 lossy=1974272
->  Bitmap Index Scan on chartevents_idx02  (cost=0.00..104182.19 rows=5641283 width=0) (actual time=653.446..653.446 rows=5190683 loops=1)
Index Cond: (itemid = 211)
->  Hash  (cost=1333.32..1333.32 rows=61532 width=12) (actual time=37.130..37.130 rows=61532 loops=1)
Buckets: 8192  Batches: 1  Memory Usage: 2885kB
->  Seq Scan on icustays ie  (cost=0.00..1333.32 rows=61532 width=12) (actual time=0.018..21.791 rows=61532 loops=1)
Planning time: 0.748 ms
Execution time: 22863.388 ms
(20 rows)
```

```
QUERY PLAN                                                                            
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
GroupAggregate  (cost=4000980.57..4010697.40 rows=61532 width=16) (actual time=23632.909..24003.508 rows=61532 loops=1)
Group Key: ie.icustay_id
->  Sort  (cost=4000980.57..4002497.49 rows=606767 width=16) (actual time=23632.899..23788.967 rows=975547 loops=1)
Sort Key: ie.icustay_id
Sort Method: external merge  Disk: 24440kB
->  Hash Right Join  (cost=105563.10..3932327.72 rows=606767 width=16) (actual time=737.470..22678.526 rows=975547 loops=1)
Hash Cond: (ce.icustay_id = ie.icustay_id)
Join Filter: ((ce.charttime >= ie.intime) AND (ce.charttime <= (ie.intime + '1 day'::interval day)))
Rows Removed by Join Filter: 4225921
->  Bitmap Heap Scan on chartevents ce  (cost=103460.63..3765568.96 rows=5527234 width=24) (actual time=693.981..20434.857 rows=5190683 loops=1)
Recheck Cond: (itemid = 211)
Rows Removed by Index Recheck: 144652722
Heap Blocks: exact=31233 lossy=1974272
->  Bitmap Index Scan on chartevents_idx02  (cost=0.00..102078.83 rows=5527234 width=0) (actual time=688.431..688.431 rows=5190683 loops=1)
Index Cond: (itemid = 211)
->  Hash  (cost=1333.32..1333.32 rows=61532 width=12) (actual time=43.440..43.440 rows=61532 loops=1)
Buckets: 8192  Batches: 1  Memory Usage: 2885kB
->  Seq Scan on icustays ie  (cost=0.00..1333.32 rows=61532 width=12) (actual time=0.019..25.870 rows=61532 loops=1)
Planning time: 13.701 ms
Execution time: 24007.923 ms
(20 rows)
```


## postgres-benchmark-3.sql

Okay, so far none of the indexes have given any performance boost. But maybe that's because we are only using one ITEMID. Let's try multiple ITEMIDs.

### Index on CHARTEVENTS + ICUSTAYS

```
Execution time: 32271.836 ms
```

### Detailed analysis plans


```
QUERY PLAN                                                                            
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
GroupAggregate  (cost=4117735.93..4142726.63 rows=61532 width=16) (actual time=31174.913..32264.815 rows=61532 loops=1)
Group Key: ie.icustay_id
->  Sort  (cost=4117735.93..4120173.47 rows=975015 width=16) (actual time=31174.897..31534.560 rows=1861680 loops=1)
Sort Key: ie.icustay_id
Sort Method: external merge  Disk: 46944kB
->  Hash Right Join  (cost=166737.50..4004082.50 rows=975015 width=16) (actual time=928.529..29455.574 rows=1861680 loops=1)
Hash Cond: (ce.icustay_id = ie.icustay_id)
Join Filter: ((ce.charttime >= ie.intime) AND (ce.charttime <= (ie.intime + '1 day'::interval day)))
Rows Removed by Join Filter: 7141916
->  Bitmap Heap Scan on chartevents ce  (cost=164635.03..3737393.66 rows=8881718 width=24) (actual time=883.393..25688.130 rows=9004193 loops=1)
Recheck Cond: (itemid = ANY ('{211,615,618}'::integer[]))
Rows Removed by Index Recheck: 146815831
Heap Blocks: exact=28104 lossy=2053305
->  Bitmap Index Scan on chartevents_idx02  (cost=0.00..162414.60 rows=8881718 width=0) (actual time=877.326..877.326 rows=9004193 loops=1)
Index Cond: (itemid = ANY ('{211,615,618}'::integer[]))
->  Hash  (cost=1333.32..1333.32 rows=61532 width=12) (actual time=45.066..45.066 rows=61532 loops=1)
Buckets: 8192  Batches: 1  Memory Usage: 2885kB
->  Seq Scan on icustays ie  (cost=0.00..1333.32 rows=61532 width=12) (actual time=0.020..26.737 rows=61532 loops=1)
Planning time: 0.808 ms
Execution time: 32271.836 ms
```

# Partitioning

Okay, the above showed we gained very little performance improvement by indexing. What about partitioning CHARTEVENTS?

```sql
\i postgres-hist-1.sql
```

The above code selects a particular partition, resulting in:

bucket | minitemid | maxitemid |   freq   |                        bar                         
-------- | ----------- | ----------- | ---------- | ----------------------------------------------------
     0 |        51 |    226537 | 42807988 | ==================================================
     1 |         1 |       160 | 23938561 | ============================
     2 |       161 |       427 | 26960948 | ===============================
     3 |       428 |       614 | 26813663 | ===============================
     4 |       616 |       741 | 18998658 | ======================
     5 |       742 |      3337 | 31580966 | =====================================
     6 |      3338 |      3695 | 29983368 | ===================================
     7 |      3723 |      8522 | 25904698 | ==============================
     8 |      8523 |    220073 | 12865011 | ===============
     9 |    220074 |    228647 | 23354431 | ===========================

This tells us we're getting a roughly equal distribution of the ITEMIDs across the different tables.
The first bucket, bucket 0, was hand chosen to contain most vital signs for both Metavision/CareVue. Thus, it's slightly larger.

For datetimeevents it's a similar story:

```sql
\i postgres-hist-2.sql
```

bucket | minitemid | maxitemid |  freq   |         bar          
-------- | ----------- | ----------- | --------- | ----------------------
     0 |        51 |    226537 |      39 |
     1 |         1 |       160 |     133 |
     2 |       161 |       427 |     232 |
     3 |       428 |       614 |     173 |
     4 |       616 |       741 |     109 |
     5 |       742 |      3337 |    1641 |
     6 |      3338 |      3695 |  205036 | ==
     7 |      3723 |      8522 | 1596741 | ============
     8 |      8523 |    220073 |    4515 |
     9 |    220074 |    228647 | 2689753 | ====================


Partitions are built using postgres-benchmark-4.sql. This results in a table called CHARTEVENTS_PARTITIONED which we can evaluate queries on.


## Benchmark

```sql
EXPLAIN ANALYZE
select
  ie.icustay_id
  , min(case when itemid = 211 then valuenum else null end) as HeartRate_Min
  , max(case when itemid = 211 then valuenum else null end) as HeartRate_Max
  , min(case when itemid in (615,618) then valuenum else null end) as RespRate_Min
  , max(case when itemid in (615,618) then valuenum else null end) as RespRate_Max
from icustays ie
-- join to the chartevents table to get the observations
left join chartevents_partitioned ce
  -- match the tables on the patient identifier
  on ie.icustay_id = ce.icustay_id
  and ce.charttime >= ie.intime and ce.charttime <= ie.intime + interval '1' day
  and ce.itemid in (211,615,618)
group by ie.icustay_id
order by ie.icustay_id;
```

Execution plan:

```
TODO
```

Add in some indexes on ITEMID (took ~5 seconds):

```sql
drop index IF EXISTS CHARTEVENTS_PART_idx02;
CREATE INDEX CHARTEVENTS_PART_idx02
  ON CHARTEVENTS_PARTITIONED (ITEMID);
```

Re-run explain analyze:

```sql
EXPLAIN ANALYZE
select
  ie.icustay_id
  , min(case when itemid = 211 then valuenum else null end) as HeartRate_Min
  , max(case when itemid = 211 then valuenum else null end) as HeartRate_Max
  , min(case when itemid in (615,618) then valuenum else null end) as RespRate_Min
  , max(case when itemid in (615,618) then valuenum else null end) as RespRate_Max
from icustays ie
-- join to the chartevents table to get the observations
left join chartevents_partitioned ce
  -- match the tables on the patient identifier
  on ie.icustay_id = ce.icustay_id
  and ce.charttime >= ie.intime and ce.charttime <= ie.intime + interval '1' day
  and ce.itemid in (211,615,618)
group by ie.icustay_id
order by ie.icustay_id;
```

Should be faster.

```
TODO
```
