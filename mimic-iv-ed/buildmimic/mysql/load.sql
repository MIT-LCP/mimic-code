-- csv2mysql with arguments:
--   -o
--   load1.sql
--   -e
--   
--   -u
--   -s
--   -z
--   -p
--   -k
--   diagnosis.csv
--   edstays.csv
--   medrecon.csv
--   pyxis.csv
--   triage.csv
--   vitalsign.csv

warnings

DROP TABLE IF EXISTS diagnosis;
CREATE TABLE diagnosis (	-- rows=946692
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   stay_id INT NOT NULL,	-- range: [30000012, 39999965]
   seq_num TINYINT NOT NULL,	-- range: [1, 9]
   icd_code VARCHAR(255) NOT NULL,	-- max length=7
   icd_version TINYINT NOT NULL,	-- range: [9, 10]
   icd_title TEXT NOT NULL	-- max length=149
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'diagnosis.csv' INTO TABLE diagnosis
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@stay_id,@seq_num,@icd_code,@icd_version,@icd_title)
 SET
   subject_id = trim(@subject_id),
   stay_id = trim(@stay_id),
   seq_num = trim(@seq_num),
   icd_code = trim(@icd_code),
   icd_version = trim(@icd_version),
   icd_title = trim(@icd_title);

DROP TABLE IF EXISTS edstays;
CREATE TABLE edstays (	-- rows=447712
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT,	-- range: [20000019, 29999809]
   stay_id INT NOT NULL,	-- range: [30000012, 39999965]
   intime DATETIME NOT NULL,
   outtime DATETIME NOT NULL,
   gender VARCHAR(255) NOT NULL,	-- max length=1
   race VARCHAR(255) NOT NULL,	-- max length=41
   arrival_transport VARCHAR(255) NOT NULL,	-- max length=10
   disposition VARCHAR(255) NOT NULL,	-- max length=27
  UNIQUE KEY edstays_stay_id (stay_id)	-- nvals=447712
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'edstays.csv' INTO TABLE edstays
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@intime,@outtime,@gender,@race,@arrival_transport,@disposition)
 SET
   subject_id = trim(@subject_id),
   hadm_id = IF(@hadm_id='', NULL, trim(@hadm_id)),
   stay_id = trim(@stay_id),
   intime = trim(@intime),
   outtime = trim(@outtime),
   gender = trim(@gender),
   race = trim(@race),
   arrival_transport = trim(@arrival_transport),
   disposition = trim(@disposition);

DROP TABLE IF EXISTS medrecon;
CREATE TABLE medrecon (	-- rows=3143791
   subject_id INT NOT NULL,	-- range: [10000032, 19999828]
   stay_id INT NOT NULL,	-- range: [30000012, 39999964]
   charttime DATETIME NOT NULL,
   name TEXT NOT NULL,	-- max length=127
   gsn VARCHAR(255) NOT NULL,	-- max length=6
   ndc VARCHAR(255) NOT NULL,	-- max length=11
   etc_rn TINYINT NOT NULL,	-- range: [1, 5]
   etccode VARCHAR(255),	-- max length=8
   etcdescription VARCHAR(255)	-- max length=70
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'medrecon.csv' INTO TABLE medrecon
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@stay_id,@charttime,@name,@gsn,@ndc,@etc_rn,@etccode,@etcdescription)
 SET
   subject_id = trim(@subject_id),
   stay_id = trim(@stay_id),
   charttime = trim(@charttime),
   name = trim(@name),
   gsn = trim(@gsn),
   ndc = trim(@ndc),
   etc_rn = trim(@etc_rn),
   etccode = IF(@etccode='', NULL, trim(@etccode)),
   etcdescription = IF(@etcdescription='', NULL, trim(@etcdescription));

DROP TABLE IF EXISTS pyxis;
CREATE TABLE pyxis (	-- rows=1670590
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   stay_id INT NOT NULL,	-- range: [30000012, 39999964]
   charttime DATETIME NOT NULL,
   med_rn SMALLINT NOT NULL,	-- range: [1, 177]
   name VARCHAR(255) NOT NULL,	-- max length=45
   gsn_rn TINYINT NOT NULL,	-- range: [1, 4]
   gsn VARCHAR(255)	-- max length=6
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'pyxis.csv' INTO TABLE pyxis
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@stay_id,@charttime,@med_rn,@name,@gsn_rn,@gsn)
 SET
   subject_id = trim(@subject_id),
   stay_id = trim(@stay_id),
   charttime = trim(@charttime),
   med_rn = trim(@med_rn),
   name = trim(@name),
   gsn_rn = trim(@gsn_rn),
   gsn = IF(@gsn='', NULL, trim(@gsn));

DROP TABLE IF EXISTS triage;
CREATE TABLE triage (	-- rows=447712
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   stay_id INT NOT NULL,	-- range: [30000012, 39999965]
   temperature FLOAT,
   heartrate FLOAT,
   resprate FLOAT,
   o2sat FLOAT,
   sbp FLOAT,
   dbp FLOAT,
   pain VARCHAR(255),	-- max length=55
   acuity FLOAT,
   chiefcomplaint TEXT,	-- max length=136
  UNIQUE KEY triage_stay_id (stay_id)	-- nvals=447712
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'triage.csv' INTO TABLE triage
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@stay_id,@temperature,@heartrate,@resprate,@o2sat,@sbp,@dbp,@pain,@acuity,@chiefcomplaint)
 SET
   subject_id = trim(@subject_id),
   stay_id = trim(@stay_id),
   temperature = IF(@temperature='', NULL, trim(@temperature)),
   heartrate = IF(@heartrate='', NULL, trim(@heartrate)),
   resprate = IF(@resprate='', NULL, trim(@resprate)),
   o2sat = IF(@o2sat='', NULL, trim(@o2sat)),
   sbp = IF(@sbp='', NULL, trim(@sbp)),
   dbp = IF(@dbp='', NULL, trim(@dbp)),
   pain = IF(@pain='', NULL, trim(@pain)),
   acuity = IF(@acuity='', NULL, trim(@acuity)),
   chiefcomplaint = IF(@chiefcomplaint='', NULL, trim(@chiefcomplaint));

DROP TABLE IF EXISTS vitalsign;
CREATE TABLE vitalsign (	-- rows=1646976
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   stay_id INT NOT NULL,	-- range: [30000012, 39999964]
   charttime DATETIME NOT NULL,
   temperature FLOAT,
   heartrate FLOAT,
   resprate FLOAT,
   o2sat FLOAT,
   sbp SMALLINT,	-- range: [0, 1234]
   dbp MEDIUMINT,	-- range: [0, 97100]
   rhythm VARCHAR(255),	-- max length=63
   pain TEXT	-- max length=391
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'vitalsign.csv' INTO TABLE vitalsign
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@stay_id,@charttime,@temperature,@heartrate,@resprate,@o2sat,@sbp,@dbp,@rhythm,@pain)
 SET
   subject_id = trim(@subject_id),
   stay_id = trim(@stay_id),
   charttime = trim(@charttime),
   temperature = IF(@temperature='', NULL, trim(@temperature)),
   heartrate = IF(@heartrate='', NULL, trim(@heartrate)),
   resprate = IF(@resprate='', NULL, trim(@resprate)),
   o2sat = IF(@o2sat='', NULL, trim(@o2sat)),
   sbp = IF(@sbp='', NULL, trim(@sbp)),
   dbp = IF(@dbp='', NULL, trim(@dbp)),
   rhythm = IF(@rhythm='', NULL, trim(@rhythm)),
   pain = IF(@pain='', NULL, trim(@pain));

