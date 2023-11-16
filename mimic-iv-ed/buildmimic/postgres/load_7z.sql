-- -------------------------------------------------------------------------------
--
-- Load data into the MIMICIVED schema
--
-- -------------------------------------------------------------------------------

--------------------------------------------------------
--  File created - Tue 08 Jun 2023
--------------------------------------------------------

-- To run from a terminal:
--  psql "dbname=<DBNAME> user=<USER>" -v mimic_data_dir=<PATH TO DATA DIR> -f load_7z.sql

-- Change to the directory containing the data files
\cd :mimic_data_dir

-- If running scripts individually, you can set the schema where all tables are created as follows:
SET search_path TO mimiciv_ed;
-- Restoring the search path to its default value can be accomplished as follows:
-- SET search_path TO "$user",public;

/* Set the mimic_data_dir variable to point to directory containing
   all .csv files. If using Docker, this should not be changed here.
   Rather, when running the docker container, use the -v option
   to have Docker mount a host volume to the container path /mimic_data
   as explained in the README file
*/

--------------------------------------------------------
--  Load Data for Table diagnosis
--------------------------------------------------------
\echo '######################'
\echo 'Copying diagnosis.....'
\copy diagnosis FROM PROGRAM '7z e -so diagnosis.csv.gz' DELIMITER ',' CSV HEADER NULL ''
\echo 'Table diagnosis successfully generated.'

--------------------------------------------------------
--  Load Data for Table edstays
--------------------------------------------------------
\echo '###################'
\echo 'Copying edstays.....'
\copy edstays from PROGRAM '7z e -so edstays.csv.gz' delimiter ',' csv header NULL ''
\echo 'Table edstays successfully generated.'

--------------------------------------------------------
--  Load Data for Table medrecon
--------------------------------------------------------
\echo '#####################'
\echo 'Copying medrecon.....'
\copy medrecon from PROGRAM '7z e -so medrecon.csv.gz' delimiter ',' csv header NULL ''
\echo 'Table medrecon successfully generated.'

--------------------------------------------------------
--  Load Data for Table pyxis
--------------------------------------------------------
\echo '##################'
\echo 'Copying pyxis.....'
\copy pyxis from PROGRAM '7z e -so pyxis.csv.gz' delimiter ',' csv header NULL ''
\echo 'Table pyxis successfully generated.'

--------------------------------------------------------
--  Load Data for Table triage
--------------------------------------------------------
\echo '###################'
\echo 'Copying triage.....'
\copy triage from PROGRAM '7z e -so triage.csv.gz' delimiter ',' csv header NULL ''
\echo 'Table triage successfully generated.'

--------------------------------------------------------
--  Load Data for Table vitalsign
--------------------------------------------------------
\echo '######################'
\echo 'Copying vitalsign.....'
\copy vitalsign from PROGRAM '7z e -so vitalsign.csv.gz' delimiter ',' csv header NULL ''
\echo 'Table vitalsign successfully generated.'
\echo 'All tables generated.'
\echo 'THE END.'
