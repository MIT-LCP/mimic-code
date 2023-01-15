-------------------------------------------
-- Create the tables and MIMIC-IV-Note schema --
-------------------------------------------

----------------------
-- Creating schemas --
----------------------

DROP SCHEMA IF EXISTS mimiciv_note CASCADE;
CREATE SCHEMA mimiciv_note;

---------------------
-- Creating tables --
---------------------

-- schema

DROP TABLE IF EXISTS mimiciv_note.discharge;
CREATE TABLE mimiciv_note.discharge
(
  note_id VARCHAR(25) NOT NULL,
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  note_type VARCHAR(2) NOT NULL,
  note_seq SMALLINT NOT NULL,
  charttime TIMESTAMP NOT NULL,
  storetime TIMESTAMP,
  text TEXT NOT NULL
);

DROP TABLE IF EXISTS mimiciv_note.radiology;
CREATE TABLE mimiciv_note.radiology
(
  note_id VARCHAR(25) NOT NULL,
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER,
  note_type VARCHAR(2) NOT NULL,
  note_seq SMALLINT NOT NULL,
  charttime TIMESTAMP NOT NULL,
  storetime TIMESTAMP,
  text TEXT NOT NULL
);

DROP TABLE IF EXISTS mimiciv_note.discharge_detail;
CREATE TABLE mimiciv_note.discharge_detail
(
  note_id VARCHAR(25) NOT NULL,
  subject_id INTEGER NOT NULL,
  field_name VARCHAR(255) NOT NULL,
  field_value TEXT NOT NULL,
  field_ordinal INTEGER NOT NULL
);


DROP TABLE IF EXISTS mimiciv_note.radiology_detail;
CREATE TABLE mimiciv_note.radiology_detail
(
  note_id VARCHAR(25) NOT NULL,
  subject_id INTEGER NOT NULL,
  field_name VARCHAR(255) NOT NULL,
  field_value TEXT NOT NULL,
  field_ordinal INTEGER NOT NULL
);
