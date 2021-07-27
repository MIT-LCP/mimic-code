-- -------------------------------------------------------------------------------
--
-- Load data into the MIMICIVED schema
--
-- -------------------------------------------------------------------------------

--------------------------------------------------------
--  File created - Tue 08 Jun 2021
--------------------------------------------------------

-- To run from a terminal:
--  psql "dbname=<DBNAME> user=<USER>" -v mimic_data_dir=<PATH TO DATA DIR> -f load_gz.sql

-- Change to the directory containing the data files
\cd :mimic_data_dir

-- If running scripts individually, you can set the schema where all tables are created as follows:
-- SET search_path TO mimicived;
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

\copy diagnosis FROM PROGRAM 'gzip -dc diagnosis.csv.gz' DELIMITER ',' CSV HEADER NULL ''

--------------------------------------------------------
--  Load Data for Table edstays
--------------------------------------------------------

\copy edstays from edstays 'gzip -dc edstays.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table medrecon
--------------------------------------------------------

\copy medrecon from PROGRAM 'gzip -dc medrecon.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table pyxis
--------------------------------------------------------

\copy pyxis from PROGRAM 'gzip -dc pyxis.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table triage
--------------------------------------------------------

\copy triage from PROGRAM 'gzip -dc triage.csv.gz' delimiter ',' csv header NULL ''

--------------------------------------------------------
--  Load Data for Table vitalsign
--------------------------------------------------------

\copy vitalsign from PROGRAM 'gzip -dc vitalsign.csv.gz' delimiter ',' csv header NULL ''