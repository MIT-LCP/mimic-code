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

DROP TABLE IF EXISTS mimic_ed.diagnosis CASCADE;
CREATE TABLE mimic_ed.diagnosis
(
  subject_id INT NOT NULL,
  stay_id INT NOT NULL,
  seq_num INT NOT NULL,
  icd_code VARCHAR(10) NOT NULL,
  icd_version INT NOT NULL,
  icd_title VARCHAR(255) NOT NULL
) ;

--------------------------------------------------------
--  DDL for Table edstays
--------------------------------------------------------

DROP TABLE IF EXISTS mimic_ed.edstays CASCADE;
CREATE TABLE mimic_ed.edstays
(
  subject_id INT NOT NULL,
  hadm_id INT,
  stay_id INT NOT NULL,
  intime TIMESTAMP(0) NOT NULL,
  outtime TIMESTAMP(0) NOT NULL
) ;

--------------------------------------------------------
--  DDL for Table medrecon
--------------------------------------------------------

DROP TABLE IF EXISTS mimic_ed.medrecon CASCADE;
CREATE TABLE mimic_ed.medrecon
(
  subject_id INT NOT NULL,
  stay_id INT NOT NULL,
  charttime TIMESTAMP(0) NOT NULL,
  name VARCHAR(255) NOT NULL,
  gsn VARCHAR(11) NOT NULL,
  ndc VARCHAR(12) NOT NULL,
  etc_rn INT NOT NULL,
  etccode VARCHAR(8),
  etcdescription VARCHAR(255)
) ;

--------------------------------------------------------
--  DDL for Table pyxis
--------------------------------------------------------

DROP TABLE IF EXISTS mimic_ed.pyxis CASCADE;
CREATE TABLE mimic_ed.pyxis
(
  subject_id INT NOT NULL,
  stay_id INT NOT NULL,
  charttime TIMESTAMP(0) NOT NULL,
  med_rn INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  gsn_rn INT NOT NULL,
  gsn VARCHAR(6)
) ;

--------------------------------------------------------
--  PARTITION for Table triage
--------------------------------------------------------

DROP TABLE IF EXISTS mimic_ed.triage CASCADE;
CREATE TABLE mimic_ed.triage
(
  subject_id INT NOT NULL,
  stay_id INT NOT NULL,
  temperature DOUBLE PRECISION,
  heartrate DOUBLE PRECISION,
  resprate DOUBLE PRECISION,
  o2sat DOUBLE PRECISION,
  sbp DOUBLE PRECISION,
  dbp DOUBLE PRECISION,
  pain DOUBLE PRECISION,
  acuity DOUBLE PRECISION,
  chiefcomplaint VARCHAR(255)
) ;

--------------------------------------------------------
--  DDL for Table vitalsign
--------------------------------------------------------

DROP TABLE IF EXISTS mimic_ed.vitalsign CASCADE;
CREATE TABLE mimic_ed.vitalsign
(
  subject_id INT NOT NULL,
  stay_id INT NOT NULL,
  charttime TIMESTAMP(0) NOT NULL,
  temperature DOUBLE PRECISION,
  heartrate DOUBLE PRECISION,
  resprate DOUBLE PRECISION,
  o2sat DOUBLE PRECISION,
  sbp DOUBLE PRECISION,
  dbp DOUBLE PRECISION,
  rhythm TEXT,
  pain TEXT
);
