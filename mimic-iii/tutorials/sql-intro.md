
# Objectives

The goal of this tutorial is to introduce working with the MIMIC-III database using Structured Query Language (SQL). While MIMIC-III is distributed as plain text files (detailed later in this tutorial), it is easiest to work with the data within a relational database using SQL, partially due to the large number of concepts here which have been coded using SQL.

After this tutorial you should have:

- an understanding of relational databases
- an understanding of the CSV format
- familiarity with the MIMIC-III database
- ability to select data from a database using Structured Query Language (SQL)
- ability to reuse code in the MIMIC Code Repository
- ability to use SQL aggregate and window functions
- an ability to extract blood pressure measurements

# Introduction to MIMIC-III

MIMIC-III is an openly available dataset developed by the MIT Lab for Computational Physiology, comprising deidentified health data associated with >60,000 hospital stays. Spanning 2001-2012, it includes demographics, vital signs, laboratory tests, medications, and more. A paper describing MIMIC-III is available from: http://www.nature.com/articles/sdata201635

The dataset is provided as a collection of comma-separated value (CSV) files, which can be loaded into a database system such as PostgreSQL. A list of tables is provided on the MIMIC website: http://mimic.physionet.org/mimictables/admissions/

We have highlighted some of the key tables below:

- *patients*: a list of patients covered in MIMIC-III, each identified by a unique `subject_id`.
- *admissions*: a list of hospital admissions, each identified by a unique `hadm_id`.
- *icustays*: a list of ICU stays, each identified by a unique `icustay_id`.

## Exercise 1

1. Where would I find a patient's date of birth?
2. Where would I find a patient's hospital admission time?

## Solution 1

1. The patient's date of birth can be found in the *patients* table, as detailed in the documentation: http://mimic.physionet.org/mimictables/patients/
2. The patient's hospital admission time can be found in the *admissions* table, which tracks hospital admission information, as detailed here: http://mimic.physionet.org/mimictables/admissions/

# Comma separated value files

Comma separated value (CSV) files are a plain text format used for storing data in a tabular, spreadsheet-style structure. While there is no hard and fast rule for structuring tabular data, it is usually considered good practice to include a header row, to list each variable in a separate column, and to list observations in rows.

As there is no official standard for the CSV format, the term is used somewhat loosely, which can often cause issues when seeking to load the data into a data analysis package. A general recommendation is to follow the definition for CSVs set out by the Internet Engineering Task Force in the RFC 4180 specification document.

![CSV file](./csvformat.png)

Summarized briefly, RFC 4180 specifies that:

- files may optionally begin with a header row, with each field separated by a comma;
- records should be listed in subsequent rows. Fields should be separated by commas, and each row should be terminated with a line break;
- fields that contain numbers may be optionally enclosed within double quotes;
- fields that contain text ("strings") should be enclosed within double quotes;
- if a double quote appears inside a string of text then it must be escaped with a preceding double quote.

The CSV format is popular largely because of its simplicity and versatility. CSV files can be edited with a text editor, loaded as a spreadsheet in packages such as Microsoft Excel, and imported and processed by most data analysis packages. Often CSV files are an intermediate data format used to hold data that has been extracted from a relational database in preparation for analysis.

# Relational databases

Relational databases can be thought of as a collection of tables which are linked together by shared keys. Organizing data across tables can help to maintain data integrity and enable faster analysis and more efficient storage.

# Motivation: why would we want a relational database?

Imagine trying to store data about a person: their name, age, and height. We can easily save this data in a CSV:

    "Name", "Age", "Height"
    "Penny",     30,     182

Now what if we measure Penny's heart rate every hour for four hours at 8:00am, 9:00am, 10:00am, and 11:00 am.
How should we store this data? The naive approach would be to simply concatenate the information we have all in one file:

    "Name", "Age", "Height",  "Time", "Heart rate"
    "Penny",     30,      182,  "8:00",          65
    "Penny",     30,      182,  "9:00",          71
    "Penny",     30,      182, "10:00",          72
    "Penny",     30,      182, "11:00",          68

This works, but it feels very inefficient. We have repeated her name ("Penny"), her age (30), and her height (182) every time we get a heart rate measurement. The immediate solution is to not store both of these in the same file: we make one file for Penny's demographics (age, height), and we make another file for heart rate measurements. Then, we make sure that her name is the same in both, so that we know that both sets of data relate to Penny. We've created a relational database. Since her name is what links the two tables together, we would call the name column a "key".

# Database terminology

- "Database schema": The model that defines the structure and relationships of the tables.
- "Database query": Data is extracted from relational databases using structured "queries".
- "Primary key": A primary key is a field that uniquely identifies each row in a table.
- "Foreign key": A foreign key is a field that refers to a primary key in another table.
- "Normalisation": The concept of structuring a database in a way that reduces data repetition and improves data integrity, usually by requiring one or more tables to be joined.
- "Denormalisation": The concept of structuring a database to improve readability, sometimes at the expense of data repetition and data integrity.
- "Data type": A term used to describe the behaviour of data and the possible values that it can hold (for example, integer, text, and date are all data types in PostgreSQL).

Giving a simple example of a hospital database with four tables, it might comprise of: Table 1, a list of all patients; Table 2, a log of hospital admissions; Table 3, a list of vital sign measurements; Table 4, a dictionary of vital sign codes and associated labels.

The patients table lists unique patients. The admissions table lists unique hospital admissions. The chartevents table lists charted events such as heart rate measurements. The `d_items` table is a dictionary that lists `itemid`s and associated labels, as shown in the example query. pk is primary key. fk is foreign key.

![Relational databases consist of multiple data tables linked by keys.](./relationaldb.png)

# What is Structured Query Language (SQL)?

Structured Query Language (SQL) is a programming language used to manage relational databases.
An SQL query has the following format:

```
SELECT [columns]
FROM [table_name];
```

The result of a query is generally a list of rows selected from your table/s of interest. For example, the following query lists the unique patient identifiers (`subject_id`s) of all female patients:

```
SELECT subject_id
FROM patients;
```

The `*` character is a wildcard that can be used to select all columns.

```
SELECT *
FROM patients;
```

## Exercise 2

1. Open your database querying tool (e.g. PgAdmin3) and connect to the MIMIC-III database.
2. Select all the data from the patients table
3. Select only the `subject_id`, `dob`, and `gender` columns from the patients table

## Solution 2

1. If you have not installed the MIMIC-III database into a PostgreSQL server either locally or otherwise, you can follow the tutorial on installing MIMIC-III:
    * OS X or Ubuntu: http://mimic.physionet.org/tutorials/install-mimic-locally-ubuntu/
    * Windows: http://mimic.physionet.org/tutorials/install-mimic-locally-windows/
2. `SELECT * FROM patients`
3. `SELECT subject_id, dob, gender FROM patients`


# `WHERE` keyword

Often you will want to select a subset of the data which satisfy some set of conditions.
For example, you may want to select only female subjects from the database.
This is easily accomplished with the `WHERE` keyword. The framework of our query becomes:

```
SELECT [columns]
FROM [table_name]
WHERE [conditions];
```

We can easily select all the `subject_id` corresponding to female subjects as follows:

```
SELECT subject_id
FROM patients
WHERE gender = 'F';
```

`WHERE` clauses are used to make a query return rows meeting only our specified criteria (our previous query, for example, returning only female patients). The simplest criteria is equality, `WHERE gender = 'F'`. Note that in this situation we specify a string, but this syntax will work for numbers as well. For example, we could select all the data for a single subject:

```
SELECT *
FROM patients
WHERE subject_id = 109;
```

`WHERE` clauses can be combined with standard logical operators `AND`/`OR`:

```
SELECT *
FROM patients
WHERE subject_id = 109
OR subject_id = 117
OR subject_id = 127;
```

A useful shorthand for `OR` statements on the same column is the `IN` condition:

```
SELECT *
FROM patients
WHERE subject_id IN (109, 117, 127);
```

We can also use the "less than" (`<`), "less than or equal to" `<=`, "greater than" (`>`), or "greater than or equal to" `>=` operators:

```
SELECT *
FROM patients
WHERE subject_id >= 109
AND subject_id <= 127;
```

SQL also offers shorthand for `>=` and `<=` combinations with the `BETWEEN` condition:

```
SELECT *
FROM patients
WHERE subject_id BETWEEN 109 AND 127;
```

Note the `BETWEEN` operator is inclusive. Verify for yourself that the above two queries give the same result.

When working with text data, we'll often want to search for partial string matches rather than exact matches. This can be accomplished with the `LIKE` keyword:

```
-- use `LIKE` to match text
-- The `%` is a wildcard that will match all characters
SELECT *
FROM icustays
WHERE first_careunit LIKE '%ICU%';
```

Note the use of the wildcard character `%`.

## Exercise 3

1. Investigate the importance of the wildcard character `%`. To do this, execute the following two queries. What is the difference in output between these two queries? Why do the outputs differ?

```
SELECT *
FROM icustays
WHERE first_careunit LIKE 'ICU%';
```

... and:

```
SELECT *
FROM icustays
WHERE first_careunit LIKE '%ICU';
```

2. How many rows are returned when you select all columns from the *patients* table where the gender is 'M'? How many rows are returned when the gender is 'm'? Why is the number different?
3. Each row in the *icustays* table represents a patient stay in the ICU. For hospital stay ID (`hadm_id`) 100242, how many times did the patient visit the ICU? How many days was his/her longest ICU stay on this hospital visit?
4. Which table would you check to find the gender of this patient? Is the patient male or female?

## Solutions

1. `LIKE 'ICU%'` requires the string to begin with the word 'ICU': i.e. it will match 'ICU' but it *will not match* 'SICU' since the string does not begin with 'ICU'. Conversely, `LIKE '%ICU'` requires the string to end in 'ICU', and will match 'SICU' but would not match 'ICU-B'. In the MIMIC-III database, careunits always end in the string 'ICU', so the first query returns no results, while the second query returns many rows.
2. String comparisons are case sensitive - `SELECT * FROM patients WHERE gender = 'M'` returns many rows but `SELECT * FROM patients WHERE gender = 'm'` returns no rows. You can avoid this issue by using `lower()` to convert all case to lower case, e.g. `SELECT * FROM patients WHERE lower(gender) = 'm'`.
3. `SELECT * FROM icustays WHERE hadm_id = 100242`. We can see the hospital admission has three unique `icustay_id` associated with it, therefore we can conclude the patient was admitted to the ICU three times. The longest ICU stay was approximately 3 days, as given by the `los` column.
4. The *patients* table has gender, and so we need to find the `subject_id` associated with the given `hadm_id` and select from the *patients* table. `SELECT gender FROM patients WHERE subject_id = 18996` tells us the patient was male.


# ORDER BY keyword

The `ORDER BY` keyword is relatively straightforward: it will sort the data in the order you specify.

```
SELECT [columns]
FROM [table_name]
WHERE [conditions]
ORDER BY [columns];
```

The below query orders the results by the patient `dob`

```
SELECT subject_id, dob
FROM patients
ORDER BY dob;
```

Note that the `WHERE` clause is optional, and in the above query we have omitted it. However, we must respect the order of the keywords - and if we use the `WHERE` keyword it must appear after the `FROM` keyword and before the `ORDER BY` keyword.

## Exercise 4

1. Write a query that selects all of the data in the admissions table, sorted by ascending hospital admission ID (`hadm_id`). What is the lowest `hadm_id`?

## Solution 4

1. `SELECT hadm_id FROM admissions ORDER BY hadm_id` gives us the lowest `hadm_id`: 100001.

# Using SQL JOIN to query multiple tables

Often we need information coming from multiple tables. This can be achieved using the SQL `JOIN` keyword. There are several types of join, including `INNER JOIN`, `LEFT JOIN`, and `RIGHT JOIN`. It is important to understand the difference between these joins because their usage can significantly impact query results. Detailed guidance on joins is widely available on the web.

![SQL joins. Adapted from an image by Arbeck on Wikipedia: https://commons.wikimedia.org/wiki/File:SQL_Joins.svg](./sql-joins.png)

Using the `INNER JOIN` keyword, let’s select a list of patients from the *patients* table along with dates of birth, and join to the *admissions* table to get the admission time for each hospital admission. We use the `INNER JOIN` to indicate that two or more tables should be combined based on a common attribute, which in our case is `subject_id`:

```
-- INNER JOIN will only return rows where subject_id
-- appears in both the patients table and the admissions table
SELECT p.subject_id, p.dob, a.hadm_id, a.admittime
FROM patients p
INNER JOIN admissions a
ON p.subject_id = a.subject_id
ORDER BY subject_id, hadm_id;
```

## Exercise 5

1. Join the *admissions* table to the *icustays* table
2. Join the *patients* table to both the *admissions* table and the *icustays* table

## Solution 5

1. Two equivalent answers:
    * `SELECT * FROM admissions INNER JOIN icustays ON admissions.hadm_id = icustays.hadm_id`
    * `SELECT * FROM admissions adm INNER JOIN icustays icu ON adm.hadm_id = icu.hadm_id`
2.
```sql
SELECT * FROM icustays icu
INNER JOIN admissions adm
  ON icu.hadm_id = adm.hadm_id
INNER JOIN patients pat
  on icu.subject_id = pat.subject_id
```

# Performing operations on columns

Sometimes we will want to perform operations on columns. For example, if we are only interested in length of stay (`los`) to the nearest day, we can use the `round` function:

```
SELECT icustay_id, round(los)
FROM icustays;
```

Note that the column name ends up being `round(los)`. We can specify the column name using the `AS` keyword:

```
SELECT icustay_id, round(los) AS los_integer_days
FROM icustays;
```

There are a large number of operations available in PostgreSQL (e.g. a list of mathematical operators are listed [here](https://www.postgresql.org/docs/9.5/static/functions-math.html)).

Operations can involve multiple columns at once. For example, we may be interested in calculating, for patients who died, how long they spent in the hospital:

```
-- When combining columns in an operation, it is sometimes necessary
-- to convert ('cast') them to the same data type
SELECT subject_id, admittime, deathtime
  , deathtime - admittime AS length_of_stay
FROM admissions
WHERE deathtime IS NOT NULL;
```

Here we have introduced another concept: the `IS NOT NULL` clause which checks that the value is not null (a "null" is an empty value, and represents missing data).

# How can we use temporary tables to help manage queries?

It is sometimes helpful to create temporary views or tables to break a large query into smaller, more manageable chunks. There are several approaches that can be used to create temporary tables. One method uses the `WITH` keyword. For example, we'll create a temporary view called `patient_dates` using the previous query, and then select all of its columns:

```
WITH patient_dates AS (
SELECT p.subject_id, p.dob, a.hadm_id, a.admittime,
    ( (cast(a.admittime as date) - cast(p.dob as date)) / 365.2 ) as age
FROM patients p
INNER JOIN admissions a
ON p.subject_id = a.subject_id
ORDER BY subject_id, hadm_id
)
SELECT *
FROM patient_dates;
```

Another method is "materialised views", which create a new table on your database schema. We can then treat this view as any other database table.

```
-- we begin by dropping any existing views with the same name
DROP MATERIALIZED VIEW IF EXISTS patient_dates_view;
CREATE MATERIALIZED VIEW patient_dates_view AS
SELECT p.subject_id, p.dob, a.hadm_id, a.admittime,
    ( (cast(a.admittime as date) - cast(p.dob as date)) / 365.2 ) as age
FROM patients p
INNER JOIN admissions a
ON p.subject_id = a.subject_id
ORDER BY subject_id, hadm_id;
```

# CASE statement for if/else logic

The `CASE` statement is used to handle if/else logic. For example, using the *icustays* table you may want to group length of ICU stay (`los`) into short, medium, and long:

```sql
-- Use if/else logic to categorise length of stay
-- into 'short', 'medium', and 'long'
SELECT subject_id, hadm_id, icustay_id, los,
    CASE WHEN los < 2 THEN 'short'
         WHEN los >=2 AND los < 7 THEN 'medium'
         WHEN los >=7 THEN 'long'
         ELSE NULL END AS los_group
FROM icustays;
```

## Exercise 6

Write a query that selects `subject_id` and `gender` from the *patients* table and adds a column that codes the gender as 0/1 (female/male)

## Solution 6

```sql
SELECT subject_id, gender
, CASE WHEN gender = 'M' then 1
       WHEN gender = 'F' then 0
  ELSE NULL END
  as gender_binary
FROM patients;
```

# Aggregate functions

We are often interested in finding an aggregate value across multiple rows, such as the number of patients meeting a condition, an average heart rate, or a maximum blood pressure. We can do this using aggregate functions, such as `COUNT()`, `MAX()`, `SUM()`, and `AVG()`.

Count the number of rows in the *icustays* table with the `COUNT()` function:

```sql
-- count the number of rows in a table
SELECT count(*)
FROM icustays;
```

Find the maximum length of stay in the *icustays* table with the `MAX()` function:

```sql
-- find the maximum length of stay in the ICU
SELECT MAX(los)
FROM icustays;
```

Aggregate are often combined with a `GROUP BY` clause, so that the aggregate function is applied to specific groups. For example, we can find the maximum length of stay, grouped for each patient:

```sql
-- find the maximum length of stay in the ICU
-- for each patient
SELECT subject_id, MAX(los)
FROM icustays
GROUP BY subject_id;
```

We may want to add a condition based on our new aggregate column. The `WHERE` clause won’t filter on an aggregate column, so instead we use the `HAVING` keyword. For example, we can find the maximum length of stay, grouped for each patient, returning only patients whose maximum stay is less than 10 days:

```sql
-- find the maximum length of stay in the ICU
-- for each patient
-- where the maximum length of stay is < 10 days
SELECT subject_id, MAX(los)
FROM icustays
GROUP BY subject_id
HAVING MAX(los) <= 10;
```

## Exercise 7

The `chartevents` table contains charted data such as vital sign measurements. The `itemid`s `211` and `220045` correspond to heart rate (you can double check this in the `d_items` table).

1. Write a query to select all of the heart rate measurements in the `chartevents` table. Use the `GROUP BY` keyword to find the maximum heart rate for each patient. Note this query may take a some time.
2. Modify the query to exclude patients with a maximum heart rate of > 140 bpm.

## Solution 7

1.
```sql
SELECT icustay_id, max(valuenum) as HeartRate_Max
FROM chartevents
WHERE itemid = 211
GROUP BY icustay_id;
```
2.
```sql
SELECT icustay_id, max(valuenum) as HeartRate_Max
FROM chartevents
WHERE itemid = 211
GROUP BY icustay_id
HAVING max(valuenum) <= 140;
```

# Window functions

Sometimes an aggregate function isn't quite what we need. For example, we might want to create a column that lists the order of admissions to the ICU for each patient. In this case we do not want to group all of the rows with the same `subject_id` into a single row, so a simple a aggregate function is insufficient. Instead, we want to return multiple rows for each `subject_id`, with the order of admission computed over a `subject_id` window. For example, let's find the order of admission to the ICU for each patient using the `RANK()` window function:

```sql
-- find the order of admissions to the ICU for a patient
SELECT subject_id, icustay_id, intime,
    RANK() OVER (PARTITION BY subject_id ORDER BY intime)
FROM icustays;
```

We can then combine this query with a temporary table to select only the first ICU stay for each patient:

```sql
WITH icustayorder AS (
SELECT subject_id, icustay_id, intime,
  RANK() OVER (PARTITION BY subject_id ORDER BY intime)
FROM icustays
)
SELECT *
FROM icustayorder
WHERE rank = 1;
```

## Exercise 8

1. Extract the length of stay of the each patient's first ICU stay.
2. Filter to only patients who stayed for at least one day.

## Solution 8

1.
```sql
WITH icustayorder AS (
SELECT subject_id, icustay_id, intime,
  RANK() OVER (PARTITION BY subject_id ORDER BY intime),
  los
FROM icustays
)
SELECT subject_id, icustay_id, intime, los
FROM icustayorder
WHERE rank = 1;
```
2.
```sql
WITH icustayorder AS (
SELECT subject_id, icustay_id, intime,
  RANK() OVER (PARTITION BY subject_id ORDER BY intime),
  los
FROM icustays
)
SELECT subject_id, icustay_id, intime, los
FROM icustayorder
WHERE rank = 1
AND los >= 1;
```

# Multiple temporary views

Using the `WITH` statement, you can have more than one inline view. The `services` table contains information about what type of care a patient is receiving in the hospital.

```sql
-- find the care service provided to each hospital admission
SELECT subject_id, hadm_id, transfertime, prev_service, curr_service
FROM services;
```

Note that the `services` table doesn't have `icustay_id`, but we can join to it using `hadm_id`.

```sql
WITH serv as (
  SELECT subject_id, hadm_id, transfertime, prev_service, curr_service
  FROM services
)
, icu as
(
  SELECT subject_id, hadm_id, icustay_id, intime, outtime
  FROM icustays
)
SELECT icu.subject_id, icu.hadm_id, icu.icustay_id, icu.intime, icu.outtime
, serv.transfertime, serv.prev_service, serv.curr_service
FROM icu
INNER JOIN serv
ON icu.hadm_id = serv.hadm_id
```

However, something subtle has happened in this join. Let's see how many rows of data are returned by the above query. We can do this using the aggregate operator `COUNT()`:


```sql
WITH serv as (
  SELECT subject_id, hadm_id, transfertime, prev_service, curr_service
  FROM services
)
, icu as
(
  SELECT subject_id, hadm_id, icustay_id, intime, outtime
  FROM icustays
)
SELECT COUNT(*)
FROM icu
INNER JOIN serv
ON icu.hadm_id = serv.hadm_id
```

Notice we have replaced all the column names with `COUNT(*)` - which means "count all the rows". What result do you get? Let's compare it to the original *icustays* table:

```sql
SELECT count(*)
FROM icustays;
```

## Exercise 9

1. Was there a difference between the two counts above? Can you explain why or why there wouldn't be?
2. Suggest an alternative query, making use of the aggregate functions, which would ensure no change in row count (Hint: perhaps we only want the *first* service).

## Solution 9

1. Yes. Intuitively, each hospital admission (`hadm_id`) can have multiple service types (i.e. the patient transferred from surgical to medical), and can have multiple ICU stays (i.e. the patient was readmitted to the ICU). As a result, the first query duplicates rows by matching every service the patient was under to every ICU stay the patient had, regardless of whether they match. This is because we are only joining on `hadm_id`, so the only constraint is that the two events occurred in the same hospitalization. Of course, we do not want this to happen, since a patient is only ever on one service at a time. More technically, the first query joined two tables on non-unique keys: there may be multiple `hadm_id` with the same value in the *services* table, and there may be multiple `hadm_id` with the same value in the *admissions* table. For example, if the *services* table has `hadm_id = 100001` repeated N times, and the *admissions* table has `hadm_id = 100001` repeated M times, then joining these two on `hadm_id` will result in a table with NxM rows: one for every pair. With MIMIC, it is generally very bad practice to join two tables on non-unique columns: at least one of the tables should have unique values for the column, otherwise you end up with duplicate rows and the query results can be confusing.
2. Note the addition of `AND serv.rank = 1` causes the first table to have unique `hadm_id`.
```sql
WITH serv as (
  SELECT subject_id, hadm_id, transfertime, prev_service, curr_service,
    RANK() OVER (PARTITION BY hadm_id ORDER BY transfertime) as rank
  FROM services
)
, icu as
(
  SELECT subject_id, hadm_id, icustay_id, intime, outtime
  FROM icustays
)
SELECT COUNT(*)
FROM icu
INNER JOIN serv
ON icu.hadm_id = serv.hadm_id
AND serv.rank = 1;
```

# Using other concepts available in the MIMIC Code Repository

The MIMIC Code Repository is a repository of code shared by the research community - it's where this tutorial is hosted! It is intended to be a central hub for sharing, refining, and reusing code used for analysis of the MIMIC critical care database. For example, you may be interested in identifying which patients have severe sepsis according to the [Angus Criteria](https://github.com/MIT-LCP/mimic-code/blob/main/mimic-iii/concepts/sepsis/angus2001.pdf). Rather than re-implementing the criteria, you can make use of existing code in the MIMIC Code Repository.

A materialised view for the Angus Criteria is available at: https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iii/concepts/sepsis/angus.sql. Running this query will generate a table with columns for `subject_id`,`hadm_id`, and `angus` status.

## Exercise 10

Build a materialized view of the Angus criteria on your local database using the code at: https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iii/concepts/sepsis/angus.sql

## Solution 10

If you are running psql, you can call files as follows:

```sql
\i angus.sql
```

Which should return:

```
DROP MATERIALIZED VIEW
SELECT 58976
```

Or, you may instead get a warning that the view did not exist - that's fine too. If you are running the query in a GUI such as PgAdmin3 or PgAdmin4, then you may simply see `Query returned with no results`. That's expected - the results have been saved into a materialized view. Try to select from the view: `SELECT * FROM angus`. If it returns rows, you've built the view successfully.

# Conclusion

Now you should be able to query the MIMIC-III database and take advantage of already created concepts - good luck! If you have issues while working with MIMIC or any of the concepts, feel free to raise them at: https://github.com/MIT-LCP/mimic-code
