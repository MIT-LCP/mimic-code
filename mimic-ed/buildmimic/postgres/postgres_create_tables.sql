-- -------------------------------------------------------------------------------
--
-- Create the MIMIC-ED tables
--
-- -------------------------------------------------------------------------------

--------------------------------------------------------
--  File created - Tue 08 Jun 2021
--------------------------------------------------------

-- If running scripts individually, you can set the schema where all tables are created as follows:
-- SET search_path TO mimicived;

-- Restoring the search path to its default value can be accomplished as follows:
--  SET search_path TO "$user",public;

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
  SEQ_NUM INT,
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
  HADM_ID INT NOT NULL,
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
  NAME VARCHAR(255),
  GSN VARCHAR(11),
  NDC VARCHAR(6),
  ETC_RN INT,
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
  STAY_ID INT NOT NULL,,
  CHARTTIME TIMESTAMP(0) NOT NULL,
  MED_RN INT,
  NAME VARCHAR(255),
  GSN_RN INT,
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