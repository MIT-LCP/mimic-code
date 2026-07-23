---------------------------------------------
-- Load data into the MIMIC-IV-Note schema --
---------------------------------------------

-- To run from a terminal:
--  psql "dbname=<DBNAME> user=<USER>" -v mimic_data_dir=<PATH TO DATA DIR> -f load_gz.sql
\cd :mimic_data_dir

-- making sure that all tables are emtpy and correct encoding is defined -utf8- 
SET CLIENT_ENCODING TO 'utf8';

\COPY mimiciv_note.discharge FROM 'discharge.csv' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_note.radiology FROM 'radiology.csv' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_note.discharge_detail FROM 'discharge_detail.csv' DELIMITER ',' CSV HEADER NULL '';
\COPY mimiciv_note.radiology_detail FROM 'radiology_detail.csv' DELIMITER ',' CSV HEADER NULL '';
