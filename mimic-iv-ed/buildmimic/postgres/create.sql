-- -------------------------------------------------------------------------------
--
-- Create the MIMIC-ED tables
--
-- -------------------------------------------------------------------------------

--------------------------------------------------------
--  File created - Wed 13 Jul 2022
--------------------------------------------------------

DROP SCHEMA IF EXISTS mimiciv_ed CASCADE;
CREATE SCHEMA mimiciv_ed;

/* Set the mimic_data_dir variable to point to directory containing
   all .csv files. If using Docker, this should not be changed here.
   Rather, when running the docker container, use the -v option
   to have Docker mount a host volume to the container path /mimic_data
   as explained in the README file
*/


--------------------------------------------------------
--  DDL for Table diagnosis
--------------------------------------------------------

DROP TABLE IF EXISTS mimiciv_ed.diagnosis CASCADE;
CREATE TABLE mimiciv_ed.diagnosis
(
  subject_id INTEGER NOT NULL,
  stay_id INTEGER NOT NULL,
  seq_num INTEGER NOT NULL,
  icd_code VARCHAR(8) NOT NULL,
  icd_version SMALLINT NOT NULL,
  icd_title TEXT NOT NULL
) ;

--------------------------------------------------------
--  DDL for Table edstays
--------------------------------------------------------

DROP TABLE IF EXISTS mimiciv_ed.edstays CASCADE;
CREATE TABLE mimiciv_ed.edstays
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER,
  stay_id INTEGER NOT NULL,
  intime TIMESTAMP(0) NOT NULL,
  outtime TIMESTAMP(0) NOT NULL,
  gender VARCHAR(1) NOT NULL,
  race VARCHAR(60),
  arrival_transport VARCHAR(50) NOT NULL,
  disposition VARCHAR(255)
) ;

--------------------------------------------------------
--  DDL for Table medrecon
--------------------------------------------------------

DROP TABLE IF EXISTS mimiciv_ed.medrecon CASCADE;
CREATE TABLE mimiciv_ed.medrecon
(
  subject_id INTEGER NOT NULL,
  stay_id INTEGER NOT NULL,
  charttime TIMESTAMP(0),
  name VARCHAR(255),
  gsn VARCHAR(10),
  ndc VARCHAR(12),
  etc_rn SMALLINT,
  etccode VARCHAR(8),
  etcdescription VARCHAR(255)
) ;

--------------------------------------------------------
--  DDL for Table pyxis
--------------------------------------------------------

DROP TABLE IF EXISTS mimiciv_ed.pyxis CASCADE;
CREATE TABLE mimiciv_ed.pyxis
(
  subject_id INTEGER NOT NULL,
  stay_id INTEGER NOT NULL,
  charttime TIMESTAMP(0),
  med_rn SMALLINT NOT NULL,
  name VARCHAR(255),
  gsn_rn SMALLINT NOT NULL,
  gsn VARCHAR(10)
) ;

--------------------------------------------------------
--  PARTITION for Table triage
--------------------------------------------------------

DROP TABLE IF EXISTS mimiciv_ed.triage CASCADE;
CREATE TABLE mimiciv_ed.triage
(
  subject_id INTEGER NOT NULL,
  stay_id INTEGER NOT NULL,
  temperature NUMERIC,
  heartrate NUMERIC,
  resprate NUMERIC,
  o2sat NUMERIC,
  sbp NUMERIC,
  dbp NUMERIC,
  pain TEXT,
  acuity NUMERIC,
  chiefcomplaint VARCHAR(255)
) ;

--------------------------------------------------------
--  DDL for Table vitalsign
--------------------------------------------------------

DROP TABLE IF EXISTS mimiciv_ed.vitalsign CASCADE;
CREATE TABLE mimiciv_ed.vitalsign
(
  subject_id INTEGER NOT NULL,
  stay_id INTEGER NOT NULL,
  charttime TIMESTAMP(0),
  temperature NUMERIC,
  heartrate NUMERIC,
  resprate NUMERIC(10, 4),
  o2sat NUMERIC,
  sbp INTEGER,
  dbp INTEGER,
  rhythm TEXT,
  pain TEXT
);
