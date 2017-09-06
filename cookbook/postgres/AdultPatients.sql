-- -------------------------------------------------------------
-- Title: Identify Adult Patients/Hospital Admissions (>18 years of age)
-- Description: This query create a table of Adult patients and their corresponding hospital admission ID, adult 
-- is definied as age greater than or equal to 18 years. The table produced by this script called "adultpatients" contains the subject_id
-- and the corresponding hadm_id of adult patients.
-- MIMIC version: MIMIC-III v1.3
-- This query does not specify a schema, and can be directly run on your data   
-- Script Author- Prabhat Rayapati
-- contact- pr2sn@virginia.edu
---------------------------------------------------------------

-- create a copy of icustays called icustays_1
CREATE TABLE icustays_1 (LIKE	icustays);
INSERT INTO icustays_1
SELECT *
FROM icustays;

-- add the dob column to icustays_1, copy the dob data from the patients table
ALTER TABLE icustays_1
ADD dob date;

UPDATE icustays_1
SET dob=patients.dob
FROM patients
WHERE icustays_1.subject_id=patients.subject_id;

--Now lets calculate the age of the patients at the time of icu admission

ALTER TABLE icustays_1
ADD age int;

UPDATE icustays_1
SET age=date_part('year',age(cast(intime as date),dob));

-- the age of people over 89 years is scwered
-- so replace the age of anyone over 89years with 91, since the median age
-- of shifted age is 91.4

UPDATE icustays_1
SET age=91
WHERE age>89;
 
 -- Now lets create a table of adult patients only, and their corresponding hospital admissions
 CREATE TABLE icustays_2 (LIKE icustays_1);

 INSERT INTO icustays_2
 SELECT *
 FROM icustays_1;
 DELETE FROM icustays_2 
 WHERE age<18;

-- creating a table with the distinct adult hospital admissions
 CREATE TABLE adultpatients(
 	hadm_id int);
 INSERT INTO adultpatients
 SELECT distinct hadm_id
 FROM icustays_2;

-- create the table that contains the adult patients subject id and their hospital admission id
 ALTER TABLE adultpatients
 ADD subject_id int;
 UPDATE adultpatients
 SET subject_id=admissions.subject_id
 FROM admissions
 WHERE adultpatients.hadm_id=admissions.hadm_id;