-- -------------------------------------------------------------------------------
--
-- Create the MIMIC-ED tables
--
-- -------------------------------------------------------------------------------

--------------------------------------------------------
--  File created - Tue 08 Jun 2021
--------------------------------------------------------

DROP SCHEMA IF EXISTS mimic_ed CASCADE;
CREATE SCHEMA mimic_ed;

/* Set the mimic_data_dir variable to point to directory containing
   all .csv files. If using Docker, this should not be changed here.
   Rather, when running the docker container, use the -v option
   to have Docker mount a host volume to the container path /mimic_data
   as explained in the README file
*/


--------------------------------------------------------
--  DDL for Table diagnosis
--------------------------------------------------------

DROP TABLE IF EXISTS diagnosis CASCADE;
CREATE TABLE diagnosis
(
  SUBJECT_ID INT NOT NULL,
  STAY_ID INT NOT NULL,
  SEQ_NUM INT NOT NULL,
  ICD_CODE VARCHAR(10) NOT NULL,
  ICD_VERSION INT NOT NULL,
  ICD_TITLE VARCHAR(255) NOT NULL
) ;

--------------------------------------------------------
--  DDL for Table edstays
--------------------------------------------------------

DROP TABLE IF EXISTS edstays CASCADE;
CREATE TABLE edstays
(
  SUBJECT_ID INT NOT NULL,
  HADM_ID INT,
  STAY_ID INT NOT NULL,
  INTIME TIMESTAMP(0) NOT NULL,
  OUTTIME TIMESTAMP(0) NOT NULL,
  CONSTRAINT edstays_stayid_unique UNIQUE (STAY_ID)
) ;

--------------------------------------------------------
--  DDL for Table medrecon
--------------------------------------------------------

DROP TABLE IF EXISTS medrecon CASCADE;
CREATE TABLE medrecon
(
  SUBJECT_ID INT NOT NULL,
  STAY_ID INT NOT NULL,
  CHARTTIME TIMESTAMP(0) NOT NULL,
  NAME VARCHAR(255) NOT NULL,
  GSN VARCHAR(11) NOT NULL,
  NDC VARCHAR(6) NOT NULL,
  ETC_RN INT NOT NULL,
  ETCCODE VARCHAR(8),
  ETCDESCRIPTION VARCHAR(255)
) ;

--------------------------------------------------------
--  DDL for Table pyxis
--------------------------------------------------------

DROP TABLE IF EXISTS pyxis CASCADE;
CREATE TABLE pyxis
(
  SUBJECT_ID INT NOT NULL,
  STAY_ID INT NOT NULL,
  CHARTTIME TIMESTAMP(0) NOT NULL,
  MED_RN INT NOT NULL,
  NAME VARCHAR(255) NOT NULL,
  GSN_RN INT NOT NULL,
  GSN VARCHAR(6)
) ;

--------------------------------------------------------
--  PARTITION for Table triage
--------------------------------------------------------

DROP TABLE IF EXISTS triage CASCADE;
CREATE TABLE triage
(
  SUBJECT_ID INT NOT NULL,
  STAY_ID INT NOT NULL,
  TEMPERATURE DOUBLE PRECISION,
  HEARTRATE DOUBLE PRECISION,
  RESPRATE DOUBLE PRECISION,
  O2SAT DOUBLE PRECISION,
  SBP DOUBLE PRECISION,
  DBP DOUBLE PRECISION,
  PAIN INT,
  ACUITY INT,
  CHIEFCOMPLAINT VARCHAR(255)
) ;

--------------------------------------------------------
--  DDL for Table vitalsign
--------------------------------------------------------

DROP TABLE IF EXISTS vitalsign CASCADE;
CREATE TABLE vitalsign
(
  SUBJECT_ID INT NOT NULL,
  STAY_ID INT NOT NULL,
  CHARTTIME TIMESTAMP(0) NOT NULL,
  TEMPERATURE DOUBLE PRECISION,
  HEARTRATE DOUBLE PRECISION,
  RESPRATE DOUBLE PRECISION,
  O2SAT DOUBLE PRECISION,
  SBP DOUBLE PRECISION,
  DBP DOUBLE PRECISION,
  RHYTHM VARCHAR(50),
  PAIN INT
);