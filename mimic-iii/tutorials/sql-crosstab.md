# Cross Tabulation

Cross tabulation, shortened to `crosstab`, is a very common operation when working with data.
The goal is to count the number of observations stratified by two groups.

PostgreSQL is packaged with an extension which allows cross tabulation.
First, enable the extension for the database (requires PostgreSQL v9.1 or higher):

```sql
CREATE EXTENSION tablefunc;
```

You only need to run this operation *once* per database.

Let's try cross tabulating the admission and discharge locations for all hospital admissions.

First, we need to find out the unique values for the two columns:

```sql
select distinct admission_location from admissions order by admission_location;
```

... returns:

```
    admission_location
---------------------------
 CLINIC REFERRAL/PREMATURE
 EMERGENCY ROOM ADMIT
 HMO REFERRAL/SICK
 ** INFO NOT AVAILABLE **
 PHYS REFERRAL/NORMAL DELI
 TRANSFER FROM HOSP/EXTRAM
 TRANSFER FROM OTHER HEALT
 TRANSFER FROM SKILLED NUR
 TRSF WITHIN THIS FACILITY
(9 rows)
```


```sql
select distinct admission_type from admissions order by admission_type;
```

... returns:

```
 admission_type
----------------
 ELECTIVE
 EMERGENCY
 NEWBORN
 URGENT
(4 rows)
```

Now, with knowledge of the unique values, we can cross tabulate data:

```sql
SELECT *
FROM crosstab(
       'SELECT admission_location, admission_type, count(*) as ct
        FROM   admissions
        GROUP BY admission_location, admission_type
        ORDER BY 1,2'
      -- below, we list all the unique values in admission_type
      -- these will become the columns
      -- hard-coding them ensures that the order matches what we specify later
      ,$$VALUES ('ELECTIVE'::text), ('EMERGENCY'::text), ('NEWBORN'::text),  ('URGENT'::text)$$
    )
AS ct (
  -- first column has each unique value for the rows
  "Admission Location" text,
  -- now we list the columns
  "ELECTIVE" text, "EMERGENCY" text,
  "NEWBORN" text, "URGENT" text
);
```

... returns:

```
    Admission Location     | ELECTIVE | EMERGENCY | NEWBORN | URGENT
---------------------------+----------+-----------+---------+--------
 CLINIC REFERRAL/PREMATURE | 25       | 10002     | 1987    | 18
 EMERGENCY ROOM ADMIT      |          | 22754     |         |
 HMO REFERRAL/SICK         |          | 1         | 101     |
 ** INFO NOT AVAILABLE **  |          | 5         | 199     |
 PHYS REFERRAL/NORMAL DELI | 7646     | 1432      | 5553    | 448
 TRANSFER FROM HOSP/EXTRAM | 19       | 7565      | 23      | 849
 TRANSFER FROM OTHER HEALT | 3        | 61        |         | 7
 TRANSFER FROM SKILLED NUR | 13       | 246       |         | 14
 TRSF WITHIN THIS FACILITY |          | 5         |         |
(9 rows)
```

Which is an interesting view of the data! In particular, we can see some sensible counts.
Elective patients and newborn patients are never admitted from the emergency room.
Interestingly, urgent patients are never admitted from the emergency room either,
which helps highlight the subtle differences between `EMERGENCY` and `URGENT`.
