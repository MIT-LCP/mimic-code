-----------------------------------------
-- Load data into the MIMIC-IV-Note schemas --
-----------------------------------------

-- To run from a terminal:
--  psql "dbname=<DBNAME> user=<USER>" -v mimic_data_dir=<PATH TO DATA DIR> -f load_gz.sql
\cd :mimic_data_dir

-- making sure that all tables are emtpy and correct encoding is defined -utf8- 
SET CLIENT_ENCODING TO 'utf8';

\COPY mimiciv_note.discharge FROM PROGRAM '7z e -so discharge.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_note.radiology FROM PROGRAM '7z e -so radiology.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_note.discharge_detail FROM PROGRAM '7z e -so discharge_detail.csv.gz' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_note.radiology_detail FROM PROGRAM '7z e -so radiology_detail.csv.gz' DELIMITER ',' CSV HEADER NULL '';
