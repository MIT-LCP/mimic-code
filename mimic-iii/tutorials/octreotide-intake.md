# Extract durations of Octreotide intake

The data extraction process of Octreotide intake (`itemid = 225155`) turned out to be complex, considering that patients receive prescribed fluids potential interruptions or dosage changes. Therefore, rows in which a previous administration was immediately continued were joined by window functions, group-wise enumerations, and conditional expressions. We describe this in the following with obfuscated data.

Select start and end times, having grouped by `linkorderid`:

```sql
SELECT icustay_id,
       linkorderid,
       MIN(starttime) AS starttime,
       MAX(endtime)   AS endtime
FROM   inputevents_mv
WHERE  itemid = 225155
       AND statusdescription != 'Rewritten'
GROUP  BY icustay_id,
          linkorderid
ORDER  BY icustay_id,
          starttime
```

Result:

| icustay_id | linkorderid   | starttime           | endtime             |
|------------|---------------|---------------------|---------------------|
| `1111`   | 11       | 05.08.2132   00:45  | 05.08.2132   02:10  |
| 2222     | `22`     | 27.03.2136   12:54  | 28.03.2136   `00:39`|
| 2222     | `23`     | 28.03.2136   `00:39`| 28.03.2136   12:37  |
| 3333     | 33       | 15.06.2118   01:13  | 15.06.2118   13:00  |
| 3333     | 34       | 15.06.2118   13:00  | 15.06.2118   `14:30`|
| 3333     | 35       | 15.06.2118   `21:31`| 16.06.2118   09:29  |

*Notably (see `highlights`), Octreotide is given one or multiple times, although `linkorderid` is different, with zero, one or more interruptions.*

Therefore, add row number (`rn`) and indicator, whether duration continues or not (`to_prev`). Also, add enumeration based on that grouping (`gn`).

```sql
WITH t0
     AS (SELECT icustay_id,
                Min(starttime) AS starttime,
                Max(endtime)   AS endtime
         FROM   inputevents_mv
         WHERE  itemid = 225155
                AND statusdescription != 'Rewritten'
         GROUP  BY icustay_id,
                   linkorderid),
     t1
     AS (SELECT *,
                ROW_NUMBER()
                  OVER (
                    partition BY icustay_id
                    ORDER BY starttime) AS rn,
                ( CASE
                    WHEN ( LAG(endtime)
                             OVER (
                               partition BY icustay_id
                               ORDER BY starttime) = starttime ) THEN 1
                    ELSE 0
                  END )                 AS to_prev
         FROM   t0)
SELECT *,
       ROW_NUMBER()
         OVER (
           partition BY icustay_id, to_prev
           ORDER BY starttime) AS gn
FROM   t1
ORDER  BY icustay_id,
          starttime
```

Result:

| icustay_id | linkorderid | starttime        | endtime          | row | to_prev | gn |
|------------|-------------|------------------|------------------|-----|---------|----|
| 1111     | 11     | 05.08.2132 00:45 | 05.08.2132 02:10 | 1   | 0       | 1  |
| 2222     | 22     | 27.03.2136 12:54 | 28.03.2136 00:39 | 1   | 0       | 1  |
| 2222     | 23     | 28.03.2136 00:39 | 28.03.2136 12:37 | 2   | 1       | 2  |
| 3333     | 33     | 15.06.2118 01:13 | 15.06.2118 13:00 | 1   | 0       | 1  |
| 3333     | 34     | 15.06.2118 13:00 | 15.06.2118 14:30 | 2   | 1       | 1  |
| 3333     | 35     | 15.06.2118 21:31 | 16.06.2118 09:29 | 3   | 0       | 2  |

Now in case intake starts anew, set current group number. If not, return to previous group number (by `rn-gn`). Store result `group_id`.

```sql
WITH t0
     AS (SELECT icustay_id,
                Min(starttime) AS starttime,
                Max(endtime)   AS endtime
         FROM   inputevents_mv
         WHERE  itemid = 225155
                AND statusdescription != 'Rewritten'
         GROUP  BY icustay_id,
                   linkorderid),
     t1
     AS (SELECT *,
                ROW_NUMBER()
                  OVER (
                    partition BY icustay_id
                    ORDER BY starttime) AS rn,
                ( CASE
                    WHEN ( LAG(endtime)
                             OVER (
                               partition BY icustay_id
                               ORDER BY starttime) = starttime ) THEN 1
                    ELSE 0
                  END )                 AS to_prev
         FROM   t0),
     t2
     AS (SELECT *,
                ROW_NUMBER()
                  OVER (
                    partition BY icustay_id, to_prev
                    ORDER BY starttime) AS gn
         FROM   t1)
SELECT icustay_id,
       starttime,
       endtime,
       gn,
       ( CASE
           WHEN to_prev = 0 THEN gn
           ELSE ( rn - gn )
         END ) AS groupid
FROM   t2
ORDER  BY icustay_id,
          starttime
```

Result:

| icustay_id | linkorderid | starttime        | endtime          | row | to_prev | gn | group_id |
|------------|-------------|------------------|------------------|-----|---------|----|----------|
| 1111     | 11     | 05.08.2132 00:45 | 05.08.2132 02:10 | 1   | 0       | 1  | 1        |
| 2222     | 22     | 27.03.2136 12:54 | 28.03.2136 00:39 | 1   | 0       | 1  | 1        |
| 2222     | 23     | 28.03.2136 00:39 | 28.03.2136 12:37 | 2   | 1       | 2  | 1        |
| 3333     | 33     | 15.06.2118 01:13 | 15.06.2118 13:00 | 1   | 0       | 1  | 1        |
| 3333     | 34     | 15.06.2118 13:00 | 15.06.2118 14:30 | 2   | 1       | 1  | 1        |
| 3333     | 35     | 15.06.2118 21:31 | 16.06.2118 09:29 | 3   | 0       | 2  | 2        |

Now, group by `group_id`, clean up and provide `min(starttime)` and `max(endtime)` to calculate durations (`d_hours`). Also, count the number of intakes to be able to later extract the previous number of intakes (`octreo_num`).

```sql
WITH t0
     AS (SELECT icustay_id,
                Min(starttime) AS starttime,
                Max(endtime)   AS endtime
         FROM   inputevents_mv
         WHERE  itemid = 225155
                AND statusdescription != 'Rewritten'
         GROUP  BY icustay_id,
                   linkorderid),
     t1
     AS (SELECT *,
                ROW_NUMBER()
                  OVER (
                    partition BY icustay_id
                    ORDER BY starttime) AS rn,
                ( CASE
                    WHEN ( LAG(endtime)
                             OVER (
                               partition BY icustay_id
                               ORDER BY starttime) = starttime ) THEN 1
                    ELSE 0
                  END )                 AS to_prev
         FROM   t0),
     t2
     AS (SELECT *,
                ROW_NUMBER()
                  OVER (
                    partition BY icustay_id, to_prev
                    ORDER BY starttime) AS gn
         FROM   t1),
     t3
     AS (SELECT *,
                ( CASE
                    WHEN to_prev = 0 THEN gn
                    ELSE ( rn - gn )
                  END ) AS groupid
         FROM   t2)
SELECT icustay_id,
       groupid        AS octreonum,
       Min(starttime) AS starttime,
       Max(endtime)   AS endtime
FROM   t3
GROUP  BY icustay_id,
          octreonum
ORDER  BY icustay_id,
          starttime
```

Result:

| icustay_id | octreo_num | d_hours |
|------------|------------|---------|
| 1111     | 1          | 01:25   |
| 2222     | 1          | 23:43   |
| 3333     | 1          | 13:17   |
| 3333     | 2          | 11:58   |
