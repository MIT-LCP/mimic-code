-- csv2mysql with arguments:
--   -o
--   1-load-no-keys.sql
--   -e
--   
--   -u
--   -z
--   -p
--   -s
--   admissions.csv
--   caregiver.csv
--   chartevents.csv
--   d_hcpcs.csv
--   d_icd_diagnoses.csv
--   d_icd_procedures.csv
--   d_items.csv
--   d_labitems.csv
--   datetimeevents.csv
--   diagnoses_icd.csv
--   drgcodes.csv
--   emar.csv
--   emar_detail.csv
--   hcpcsevents.csv
--   icustays.csv
--   ingredientevents.csv
--   inputevents.csv
--   labevents.csv
--   microbiologyevents.csv
--   omr.csv
--   outputevents.csv
--   patients.csv
--   pharmacy.csv
--   poe.csv
--   poe_detail.csv
--   prescriptions.csv
--   procedureevents.csv
--   procedures_icd.csv
--   provider.csv
--   services.csv
--   transfers.csv

warnings

DROP TABLE IF EXISTS admissions;
CREATE TABLE admissions (	-- rows=454324
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000019, 29999928]
   admittime DATETIME NOT NULL,
   dischtime DATETIME NOT NULL,
   deathtime DATETIME,
   admission_type VARCHAR(255) NOT NULL,	-- max length=27
   admit_provider_id VARCHAR(10),
   admission_location VARCHAR(255) NOT NULL,	-- max length=38
   discharge_location VARCHAR(255),	-- max length=28
   insurance VARCHAR(255) NOT NULL,	-- max length=8
   language VARCHAR(255) NOT NULL,	-- max length=7
   marital_status VARCHAR(255),	-- max length=8
   race VARCHAR(255) NOT NULL,	-- max length=41
   edregtime DATETIME,
   edouttime DATETIME,
   hospital_expire_flag BOOLEAN NOT NULL	-- range: [0, 1]
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'admissions.csv' INTO TABLE admissions
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@admittime,@dischtime,@deathtime,@admission_type,@admit_provider_id,@admission_location,@discharge_location,@insurance,@language,@marital_status,@race,@edregtime,@edouttime,@hospital_expire_flag)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   admittime = trim(@admittime),
   dischtime = trim(@dischtime),
   deathtime = IF(@deathtime='', NULL, trim(@deathtime)),
   admission_type = trim(@admission_type),
   admit_provider_id = trim(@admit_provider_id),
   admission_location = trim(@admission_location),
   discharge_location = IF(@discharge_location='', NULL, trim(@discharge_location)),
   insurance = trim(@insurance),
   language = trim(@language),
   marital_status = IF(@marital_status='', NULL, trim(@marital_status)),
   race = trim(@race),
   edregtime = IF(@edregtime='', NULL, trim(@edregtime)),
   edouttime = IF(@edouttime='', NULL, trim(@edouttime)),
   hospital_expire_flag = trim(@hospital_expire_flag);

DROP TABLE IF EXISTS caregiver;
CREATE TABLE caregiver (	-- rows=454324
   caregiver_id INT NOT NULL
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'caregiver.csv' INTO TABLE caregiver
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@caregiver_id)
 SET
   caregiver_id = trim(@caregiver_id);

DROP TABLE IF EXISTS chartevents;
CREATE TABLE chartevents (	-- rows=329822285
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000094, 29999828]
   stay_id INT NOT NULL,	-- range: [30000153, 39999810]
   caregiver_id INT,
   charttime DATETIME NOT NULL,
   storetime DATETIME,
   itemid MEDIUMINT NOT NULL,	-- range: [220001, 229882]
   value TEXT,	-- max length=156
   valuenum FLOAT,
   valueuom VARCHAR(255),	-- max length=17
   warning BOOLEAN	-- range: [0, 1]
  )
  CHARACTER SET = UTF8MB4
  PARTITION BY HASH(itemid) PARTITIONS 50;

LOAD DATA LOCAL INFILE 'chartevents.csv' INTO TABLE chartevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@caregiver_id,@charttime,@storetime,@itemid,@value,@valuenum,@valueuom,@warning)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
   caregiver_id = IF(@caregiver_id='', NULL, trim(@caregiver_id)),
   charttime = trim(@charttime),
   storetime = IF(@storetime='', NULL, trim(@storetime)),
   itemid = trim(@itemid),
   value = IF(@value='', NULL, trim(@value)),
   valuenum = IF(@valuenum='', NULL, trim(@valuenum)),
   valueuom = IF(@valueuom='', NULL, trim(@valueuom)),
   warning = IF(@warning='', NULL, trim(@warning));

DROP TABLE IF EXISTS d_hcpcs;
CREATE TABLE d_hcpcs (	-- rows=89200
   code VARCHAR(255) NOT NULL,	-- max length=5
   category TINYINT,	-- range: [1, 3]
   long_description TEXT,	-- max length=1182
   short_description TEXT NOT NULL	-- max length=165
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'd_hcpcs.csv' INTO TABLE d_hcpcs
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@code,@category,@long_description,@short_description)
 SET
   code = trim(@code),
   category = IF(@category='', NULL, trim(@category)),
   long_description = IF(@long_description='', NULL, trim(@long_description)),
   short_description = trim(@short_description);

DROP TABLE IF EXISTS d_icd_diagnoses;
CREATE TABLE d_icd_diagnoses (	-- rows=109775
   icd_code VARCHAR(255) NOT NULL,	-- max length=7
   icd_version TINYINT NOT NULL,	-- range: [9, 10]
   long_title TEXT NOT NULL	-- max length=228
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'd_icd_diagnoses.csv' INTO TABLE d_icd_diagnoses
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@icd_code,@icd_version,@long_title)
 SET
   icd_code = trim(@icd_code),
   icd_version = trim(@icd_version),
   long_title = trim(@long_title);

DROP TABLE IF EXISTS d_icd_procedures;
CREATE TABLE d_icd_procedures (	-- rows=85257
   icd_code VARCHAR(255) NOT NULL,	-- max length=7
   icd_version TINYINT NOT NULL,	-- range: [9, 10]
   long_title TEXT NOT NULL	-- max length=163
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'd_icd_procedures.csv' INTO TABLE d_icd_procedures
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@icd_code,@icd_version,@long_title)
 SET
   icd_code = trim(@icd_code),
   icd_version = trim(@icd_version),
   long_title = trim(@long_title);

DROP TABLE IF EXISTS d_items;
CREATE TABLE d_items (	-- rows=4014
   itemid MEDIUMINT NOT NULL,	-- range: [220001, 230085]
   label TEXT NOT NULL,	-- max length=95
   abbreviation VARCHAR(255) NOT NULL,	-- max length=50
   linksto VARCHAR(255) NOT NULL,	-- max length=16
   category VARCHAR(255) NOT NULL,	-- max length=34
   unitname VARCHAR(255),	-- max length=19
   param_type VARCHAR(255) NOT NULL,	-- max length=16
   lownormalvalue SMALLINT,	-- range: [-2, 299]
   highnormalvalue FLOAT)
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'd_items.csv' INTO TABLE d_items
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@itemid,@label,@abbreviation,@linksto,@category,@unitname,@param_type,@lownormalvalue,@highnormalvalue)
 SET
   itemid = trim(@itemid),
   label = trim(@label),
   abbreviation = trim(@abbreviation),
   linksto = trim(@linksto),
   category = trim(@category),
   unitname = IF(@unitname='', NULL, trim(@unitname)),
   param_type = trim(@param_type),
   lownormalvalue = IF(@lownormalvalue='', NULL, trim(@lownormalvalue)),
   highnormalvalue = IF(@highnormalvalue='', NULL, trim(@highnormalvalue));

DROP TABLE IF EXISTS d_labitems;
CREATE TABLE d_labitems (	-- rows=1623
   itemid MEDIUMINT NOT NULL,	-- range: [50801, 53152]
   label VARCHAR(255),	-- max length=42
   fluid VARCHAR(255) NOT NULL,	-- max length=19
   category VARCHAR(255) NOT NULL	-- max length=10
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'd_labitems.csv' INTO TABLE d_labitems
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@itemid,@label,@fluid,@category)
 SET
   itemid = trim(@itemid),
   label = IF(@label='', NULL, trim(@label)),
   fluid = trim(@fluid),
   category = trim(@category);

DROP TABLE IF EXISTS datetimeevents;
CREATE TABLE datetimeevents (	-- rows=7477876
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000094, 29999828]
   stay_id INT NOT NULL,	-- range: [30000153, 39999810]
   caregiver_id INT,
   charttime DATETIME NOT NULL,
   storetime DATETIME NOT NULL,
   itemid MEDIUMINT NOT NULL,	-- range: [224183, 229891]
   value DATETIME NOT NULL,
   valueuom VARCHAR(255) NOT NULL,	-- max length=13
   warning BOOLEAN NOT NULL	-- range: [0, 1]
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'datetimeevents.csv' INTO TABLE datetimeevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@caregiver_id,@charttime,@storetime,@itemid,@value,@valueuom,@warning)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
   caregiver_id = trim(@caregiver_id),
   charttime = trim(@charttime),
   storetime = trim(@storetime),
   itemid = trim(@itemid),
   value = trim(@value),
   valueuom = trim(@valueuom),
   warning = trim(@warning);

DROP TABLE IF EXISTS diagnoses_icd;
CREATE TABLE diagnoses_icd (	-- rows=5006884
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000019, 29999928]
   seq_num TINYINT NOT NULL,	-- range: [1, 39]
   icd_code VARCHAR(255) NOT NULL,	-- max length=7
   icd_version TINYINT NOT NULL	-- range: [9, 10]
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'diagnoses_icd.csv' INTO TABLE diagnoses_icd
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@seq_num,@icd_code,@icd_version)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   seq_num = trim(@seq_num),
   icd_code = trim(@icd_code),
   icd_version = trim(@icd_version);

DROP TABLE IF EXISTS drgcodes;
CREATE TABLE drgcodes (	-- rows=636157
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000019, 29999828]
   drg_type VARCHAR(255) NOT NULL,	-- max length=4
   drg_code VARCHAR(255) NOT NULL,	-- max length=3
   description TEXT NOT NULL,	-- max length=89
   drg_severity TINYINT,	-- range: [1, 4]
   drg_mortality TINYINT	-- range: [1, 4]
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'drgcodes.csv' INTO TABLE drgcodes
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@drg_type,@drg_code,@description,@drg_severity,@drg_mortality)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   drg_type = trim(@drg_type),
   drg_code = trim(@drg_code),
   description = trim(@description),
   drg_severity = IF(@drg_severity='', NULL, trim(@drg_severity)),
   drg_mortality = IF(@drg_mortality='', NULL, trim(@drg_mortality));

DROP TABLE IF EXISTS emar;
CREATE TABLE emar (	-- rows=28189413
   subject_id INT NOT NULL,	-- range: [10000032, 19999828]
   hadm_id INT,	-- range: [20000024, 29999928]
   emar_id VARCHAR(255) NOT NULL,	-- max length=14
   emar_seq MEDIUMINT NOT NULL,	-- range: [2, 32912]
   poe_id VARCHAR(255) NOT NULL,	-- max length=14
   pharmacy_id INT,	-- range: [19, 99999975]
   enter_provider_id VARCHAR(255),
   charttime DATETIME NOT NULL,
   medication VARCHAR(255),	-- max length=75
   event_txt VARCHAR(255),	-- max length=48
   scheduletime DATETIME,
   storetime DATETIME NOT NULL)
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'emar.csv' INTO TABLE emar
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@emar_id,@emar_seq,@poe_id,@pharmacy_id,@enter_provider_id,@charttime,@medication,@event_txt,@scheduletime,@storetime)
 SET
   subject_id = trim(@subject_id),
   hadm_id = IF(@hadm_id='', NULL, trim(@hadm_id)),
   emar_id = trim(@emar_id),
   emar_seq = trim(@emar_seq),
   poe_id = trim(@poe_id),
   pharmacy_id = IF(@pharmacy_id='', NULL, trim(@pharmacy_id)),
   enter_provider_id = IF(@enter_provider_id='', NULL, trim(@enter_provider_id)),
   charttime = trim(@charttime),
   medication = IF(@medication='', NULL, trim(@medication)),
   event_txt = IF(@event_txt='', NULL, trim(@event_txt)),
   scheduletime = IF(@scheduletime='', NULL, trim(@scheduletime)),
   storetime = trim(@storetime);

DROP TABLE IF EXISTS emar_detail;
CREATE TABLE emar_detail (	-- rows=57469291
   subject_id INT NOT NULL,	-- range: [10000032, 19999828]
   emar_id VARCHAR(255) NOT NULL,	-- max length=14
   emar_seq MEDIUMINT NOT NULL,	-- range: [2, 32912]
   parent_field_ordinal FLOAT,
   administration_type VARCHAR(255),	-- max length=47
   pharmacy_id INT,	-- range: [19, 99999975]
   barcode_type VARCHAR(255),	-- max length=4
   reason_for_no_barcode VARCHAR(255),	-- max length=51
   complete_dose_not_given VARCHAR(255),	-- max length=3
   dose_due VARCHAR(255),	-- max length=19
   dose_due_unit VARCHAR(255),	-- max length=26
   dose_given VARCHAR(255),	-- max length=20
   dose_given_unit VARCHAR(255),	-- max length=26
   will_remainder_of_dose_be_given VARCHAR(255),	-- max length=3
   product_amount_given VARCHAR(255),	-- max length=23
   product_unit VARCHAR(255),	-- max length=13
   product_code VARCHAR(255),	-- max length=19
   product_description TEXT,	-- max length=129
   product_description_other TEXT,	-- max length=97
   prior_infusion_rate VARCHAR(255),	-- max length=9
   infusion_rate VARCHAR(255),	-- max length=9
   infusion_rate_adjustment VARCHAR(255),	-- max length=31
   infusion_rate_adjustment_amount VARCHAR(255),	-- max length=6
   infusion_rate_unit VARCHAR(255),	-- max length=19
   route VARCHAR(255),	-- max length=6
   infusion_complete VARCHAR(255),	-- max length=1
   completion_interval VARCHAR(255),	-- max length=23
   new_iv_bag_hung VARCHAR(255),	-- max length=1
   continued_infusion_in_other_location VARCHAR(255),	-- max length=1
   restart_interval VARCHAR(255),	-- max length=19
   side VARCHAR(255),	-- max length=6
   site VARCHAR(255),	-- max length=20
   non_formulary_visual_verification VARCHAR(255)	-- max length=1
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'emar_detail.csv' INTO TABLE emar_detail
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@emar_id,@emar_seq,@parent_field_ordinal,@administration_type,@pharmacy_id,@barcode_type,@reason_for_no_barcode,@complete_dose_not_given,@dose_due,@dose_due_unit,@dose_given,@dose_given_unit,@will_remainder_of_dose_be_given,@product_amount_given,@product_unit,@product_code,@product_description,@product_description_other,@prior_infusion_rate,@infusion_rate,@infusion_rate_adjustment,@infusion_rate_adjustment_amount,@infusion_rate_unit,@route,@infusion_complete,@completion_interval,@new_iv_bag_hung,@continued_infusion_in_other_location,@restart_interval,@side,@site,@non_formulary_visual_verification)
 SET
   subject_id = trim(@subject_id),
   emar_id = trim(@emar_id),
   emar_seq = trim(@emar_seq),
   parent_field_ordinal = IF(@parent_field_ordinal='', NULL, trim(@parent_field_ordinal)),
   administration_type = IF(@administration_type='', NULL, trim(@administration_type)),
   pharmacy_id = IF(@pharmacy_id='', NULL, trim(@pharmacy_id)),
   barcode_type = IF(@barcode_type='', NULL, trim(@barcode_type)),
   reason_for_no_barcode = IF(@reason_for_no_barcode='', NULL, trim(@reason_for_no_barcode)),
   complete_dose_not_given = IF(@complete_dose_not_given='', NULL, trim(@complete_dose_not_given)),
   dose_due = IF(@dose_due='', NULL, trim(@dose_due)),
   dose_due_unit = IF(@dose_due_unit='', NULL, trim(@dose_due_unit)),
   dose_given = IF(@dose_given='', NULL, trim(@dose_given)),
   dose_given_unit = IF(@dose_given_unit='', NULL, trim(@dose_given_unit)),
   will_remainder_of_dose_be_given = IF(@will_remainder_of_dose_be_given='', NULL, trim(@will_remainder_of_dose_be_given)),
   product_amount_given = IF(@product_amount_given='', NULL, trim(@product_amount_given)),
   product_unit = IF(@product_unit='', NULL, trim(@product_unit)),
   product_code = IF(@product_code='', NULL, trim(@product_code)),
   product_description = IF(@product_description='', NULL, trim(@product_description)),
   product_description_other = IF(@product_description_other='', NULL, trim(@product_description_other)),
   prior_infusion_rate = IF(@prior_infusion_rate='', NULL, trim(@prior_infusion_rate)),
   infusion_rate = IF(@infusion_rate='', NULL, trim(@infusion_rate)),
   infusion_rate_adjustment = IF(@infusion_rate_adjustment='', NULL, trim(@infusion_rate_adjustment)),
   infusion_rate_adjustment_amount = IF(@infusion_rate_adjustment_amount='', NULL, trim(@infusion_rate_adjustment_amount)),
   infusion_rate_unit = IF(@infusion_rate_unit='', NULL, trim(@infusion_rate_unit)),
   route = IF(@route='', NULL, trim(@route)),
   infusion_complete = IF(@infusion_complete='', NULL, trim(@infusion_complete)),
   completion_interval = IF(@completion_interval='', NULL, trim(@completion_interval)),
   new_iv_bag_hung = IF(@new_iv_bag_hung='', NULL, trim(@new_iv_bag_hung)),
   continued_infusion_in_other_location = IF(@continued_infusion_in_other_location='', NULL, trim(@continued_infusion_in_other_location)),
   restart_interval = IF(@restart_interval='', NULL, trim(@restart_interval)),
   side = IF(@side='', NULL, trim(@side)),
   site = IF(@site='', NULL, trim(@site)),
   non_formulary_visual_verification = IF(@non_formulary_visual_verification='', NULL, trim(@non_formulary_visual_verification));

DROP TABLE IF EXISTS hcpcsevents;
CREATE TABLE hcpcsevents (	-- rows=159156
   subject_id INT NOT NULL,	-- range: [10000068, 19999784]
   hadm_id INT NOT NULL,	-- range: [20000034, 29999928]
   chartdate DATE NOT NULL,
   hcpcs_cd VARCHAR(255) NOT NULL,	-- max length=5
   seq_num TINYINT NOT NULL,	-- range: [1, 15]
   short_description TEXT NOT NULL	-- max length=165
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'hcpcsevents.csv' INTO TABLE hcpcsevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@chartdate,@hcpcs_cd,@seq_num,@short_description)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   chartdate = trim(@chartdate),
   hcpcs_cd = trim(@hcpcs_cd),
   seq_num = trim(@seq_num),
   short_description = trim(@short_description);

DROP TABLE IF EXISTS icustays;
CREATE TABLE icustays (	-- rows=76943
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000094, 29999828]
   stay_id INT NOT NULL,	-- range: [30000153, 39999810]
   first_careunit VARCHAR(255) NOT NULL,	-- max length=48
   last_careunit VARCHAR(255) NOT NULL,	-- max length=48
   intime DATETIME NOT NULL,
   outtime DATETIME NOT NULL,
   los FLOAT NOT NULL)
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'icustays.csv' INTO TABLE icustays
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@first_careunit,@last_careunit,@intime,@outtime,@los)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
   first_careunit = trim(@first_careunit),
   last_careunit = trim(@last_careunit),
   intime = trim(@intime),
   outtime = trim(@outtime),
   los = trim(@los);

DROP TABLE IF EXISTS ingredientevents;
CREATE TABLE ingredientevents (	-- rows=12229408
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000094, 29999828]
   stay_id INT NOT NULL,	-- range: [30000153, 39999810]
   caregiver_id INT,
   starttime DATETIME NOT NULL,
   endtime DATETIME NOT NULL,
   storetime DATETIME NOT NULL,
   itemid MEDIUMINT NOT NULL,	-- range: [220363, 227080]
   amount FLOAT NOT NULL,
   amountuom VARCHAR(255) NOT NULL,	-- max length=5
   rate FLOAT,
   rateuom VARCHAR(255),	-- max length=10
   orderid INT NOT NULL,	-- range: [4, 9999999]
   linkorderid INT NOT NULL,	-- range: [5, 9999999]
   statusdescription VARCHAR(255) NOT NULL,	-- max length=15
   originalamount BOOLEAN NOT NULL,	-- range: [0, 0]
   originalrate FLOAT NOT NULL)
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'ingredientevents.csv' INTO TABLE ingredientevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@caregiver_id,@starttime,@endtime,@storetime,@itemid,@amount,@amountuom,@rate,@rateuom,@orderid,@linkorderid,@statusdescription,@originalamount,@originalrate)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
   caregiver_id = IF(@caregiver_id='', NULL, trim(@caregiver_id)),
   starttime = trim(@starttime),
   endtime = trim(@endtime),
   storetime = trim(@storetime),
   itemid = trim(@itemid),
   amount = trim(@amount),
   amountuom = trim(@amountuom),
   rate = IF(@rate='', NULL, trim(@rate)),
   rateuom = IF(@rateuom='', NULL, trim(@rateuom)),
   orderid = trim(@orderid),
   linkorderid = trim(@linkorderid),
   statusdescription = trim(@statusdescription),
   originalamount = trim(@originalamount),
   originalrate = trim(@originalrate);

DROP TABLE IF EXISTS inputevents;
CREATE TABLE inputevents (	-- rows=9442345
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000094, 29999828]
   stay_id INT NOT NULL,	-- range: [30000153, 39999810]
   caregiver_id INT,
   starttime DATETIME NOT NULL,
   endtime DATETIME NOT NULL,
   storetime DATETIME NOT NULL,
   itemid MEDIUMINT NOT NULL,	-- range: [220862, 229861]
   amount FLOAT NOT NULL,
   amountuom VARCHAR(255) NOT NULL,	-- max length=19
   rate FLOAT,
   rateuom VARCHAR(255),	-- max length=13
   orderid INT NOT NULL,	-- range: [2, 9999999]
   linkorderid INT NOT NULL,	-- range: [2, 9999999]
   ordercategoryname VARCHAR(255) NOT NULL,	-- max length=24
   secondaryordercategoryname VARCHAR(255),	-- max length=24
   ordercomponenttypedescription VARCHAR(255) NOT NULL,	-- max length=57
   ordercategorydescription VARCHAR(255) NOT NULL,	-- max length=14
   patientweight FLOAT NOT NULL,
   totalamount FLOAT,
   totalamountuom VARCHAR(255),	-- max length=2
   isopenbag BOOLEAN NOT NULL,	-- range: [0, 1]
   continueinnextdept BOOLEAN NOT NULL,	-- range: [0, 1]
   statusdescription VARCHAR(255) NOT NULL,	-- max length=15
   originalamount FLOAT NOT NULL,
   originalrate FLOAT NOT NULL)
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'inputevents.csv' INTO TABLE inputevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@caregiver_id,@starttime,@endtime,@storetime,@itemid,@amount,@amountuom,@rate,@rateuom,@orderid,@linkorderid,@ordercategoryname,@secondaryordercategoryname,@ordercomponenttypedescription,@ordercategorydescription,@patientweight,@totalamount,@totalamountuom,@isopenbag,@continueinnextdept,@statusdescription,@originalamount,@originalrate)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
   caregiver_id = IF(@caregiver_id='', NULL, trim(@caregiver_id)),
   starttime = trim(@starttime),
   endtime = trim(@endtime),
   storetime = trim(@storetime),
   itemid = trim(@itemid),
   amount = trim(@amount),
   amountuom = trim(@amountuom),
   rate = IF(@rate='', NULL, trim(@rate)),
   rateuom = IF(@rateuom='', NULL, trim(@rateuom)),
   orderid = trim(@orderid),
   linkorderid = trim(@linkorderid),
   ordercategoryname = trim(@ordercategoryname),
   secondaryordercategoryname = IF(@secondaryordercategoryname='', NULL, trim(@secondaryordercategoryname)),
   ordercomponenttypedescription = trim(@ordercomponenttypedescription),
   ordercategorydescription = trim(@ordercategorydescription),
   patientweight = trim(@patientweight),
   totalamount = IF(@totalamount='', NULL, trim(@totalamount)),
   totalamountuom = IF(@totalamountuom='', NULL, trim(@totalamountuom)),
   isopenbag = trim(@isopenbag),
   continueinnextdept = trim(@continueinnextdept),
   statusdescription = trim(@statusdescription),
   originalamount = trim(@originalamount),
   originalrate = trim(@originalrate);

DROP TABLE IF EXISTS labevents;
CREATE TABLE labevents (	-- rows=124342638
   labevent_id INT NOT NULL,	-- range: [1, 124532700]
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT,	-- range: [20000019, 29999928]
   specimen_id INT NOT NULL,	-- range: [2, 99999993]
   itemid MEDIUMINT NOT NULL,	-- range: [50801, 53144]
   order_provider_id VARCHAR(255),
   charttime DATETIME NOT NULL,
   storetime DATETIME,
   value TEXT,	-- max length=168
   valuenum FLOAT,
   valueuom VARCHAR(255),	-- max length=15
   ref_range_lower FLOAT,
   ref_range_upper FLOAT,
   flag VARCHAR(255),	-- max length=8
   priority VARCHAR(255),	-- max length=7
   comments TEXT	-- max length=491
  )
  CHARACTER SET = UTF8MB4
  PARTITION BY HASH(itemid) PARTITIONS 50;

LOAD DATA LOCAL INFILE 'labevents.csv' INTO TABLE labevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@labevent_id,@subject_id,@hadm_id,@specimen_id,@itemid,@order_provider_id,@charttime,@storetime,@value,@valuenum,@valueuom,@ref_range_lower,@ref_range_upper,@flag,@priority,@comments)
 SET
   labevent_id = trim(@labevent_id),
   subject_id = trim(@subject_id),
   hadm_id = IF(@hadm_id='', NULL, trim(@hadm_id)),
   specimen_id = trim(@specimen_id),
   itemid = trim(@itemid),
   order_provider_id = IF(@order_provider_id='', NULL, trim(@order_provider_id)),
   charttime = trim(@charttime),
   storetime = IF(@storetime='', NULL, trim(@storetime)),
   value = IF(@value='', NULL, trim(@value)),
   valuenum = IF(@valuenum='', NULL, trim(@valuenum)),
   valueuom = IF(@valueuom='', NULL, trim(@valueuom)),
   ref_range_lower = IF(@ref_range_lower='', NULL, trim(@ref_range_lower)),
   ref_range_upper = IF(@ref_range_upper='', NULL, trim(@ref_range_upper)),
   flag = IF(@flag='', NULL, trim(@flag)),
   priority = IF(@priority='', NULL, trim(@priority)),
   comments = IF(@comments='', NULL, trim(@comments));

DROP TABLE IF EXISTS microbiologyevents;
CREATE TABLE microbiologyevents (	-- rows=3395229
   microevent_id MEDIUMINT NOT NULL,	-- range: [1, 3395229]
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT,	-- range: [20000019, 29999828]
   micro_specimen_id INT NOT NULL,	-- range: [1, 9999993]
   order_provider_id VARCHAR(255),
   chartdate DATETIME NOT NULL,
   charttime DATETIME,
   spec_itemid MEDIUMINT NOT NULL,	-- range: [70002, 90935]
   spec_type_desc VARCHAR(255),	-- max length=56
   test_seq TINYINT NOT NULL,	-- range: [1, 24]
   storedate DATETIME,
   storetime DATETIME,
   test_itemid MEDIUMINT NOT NULL,	-- range: [90038, 90272]
   test_name VARCHAR(255) NOT NULL,	-- max length=66
   org_itemid MEDIUMINT,	-- range: [80002, 90984]
   org_name VARCHAR(255),	-- max length=70
   isolate_num TINYINT,	-- range: [1, 6]
   quantity VARCHAR(255),	-- max length=21
   ab_itemid MEDIUMINT,	-- range: [90003, 90031]
   ab_name VARCHAR(255),	-- max length=20
   dilution_text VARCHAR(255),	-- max length=6
   dilution_comparison VARCHAR(255),	-- max length=2
   dilution_value FLOAT,
   interpretation VARCHAR(255),	-- max length=1
   comments TEXT	-- max length=730
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'microbiologyevents.csv' INTO TABLE microbiologyevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@microevent_id,@subject_id,@hadm_id,@micro_specimen_id,@order_provider_id,@chartdate,@charttime,@spec_itemid,@spec_type_desc,@test_seq,@storedate,@storetime,@test_itemid,@test_name,@org_itemid,@org_name,@isolate_num,@quantity,@ab_itemid,@ab_name,@dilution_text,@dilution_comparison,@dilution_value,@interpretation,@comments)
 SET
   microevent_id = trim(@microevent_id),
   subject_id = trim(@subject_id),
   hadm_id = IF(@hadm_id='', NULL, trim(@hadm_id)),
   micro_specimen_id = trim(@micro_specimen_id),
   order_provider_id = IF(@order_provider_id='', NULL, trim(@order_provider_id)),
   chartdate = trim(@chartdate),
   charttime = IF(@charttime='', NULL, trim(@charttime)),
   spec_itemid = trim(@spec_itemid),
   spec_type_desc = IF(@spec_type_desc='', NULL, trim(@spec_type_desc)),
   test_seq = trim(@test_seq),
   storedate = IF(@storedate='', NULL, trim(@storedate)),
   storetime = IF(@storetime='', NULL, trim(@storetime)),
   test_itemid = trim(@test_itemid),
   test_name = trim(@test_name),
   org_itemid = IF(@org_itemid='', NULL, trim(@org_itemid)),
   org_name = IF(@org_name='', NULL, trim(@org_name)),
   isolate_num = IF(@isolate_num='', NULL, trim(@isolate_num)),
   quantity = IF(@quantity='', NULL, trim(@quantity)),
   ab_itemid = IF(@ab_itemid='', NULL, trim(@ab_itemid)),
   ab_name = IF(@ab_name='', NULL, trim(@ab_name)),
   dilution_text = IF(@dilution_text='', NULL, trim(@dilution_text)),
   dilution_comparison = IF(@dilution_comparison='', NULL, trim(@dilution_comparison)),
   dilution_value = IF(@dilution_value='', NULL, trim(@dilution_value)),
   interpretation = IF(@interpretation='', NULL, trim(@interpretation)),
   comments = IF(@comments='', NULL, trim(@comments));

DROP TABLE IF EXISTS omr;
CREATE TABLE omr (	-- rows=6770301
   subject_id INT NOT NULL,	-- range: [10000032, 19999828]
   chartdate DATE NOT NULL,
   seq_num TINYINT NOT NULL,	-- range: [1, 67]
   result_name VARCHAR(255) NOT NULL,	-- max length=32
   result_value VARCHAR(255) NOT NULL	-- max length=11
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'omr.csv' INTO TABLE omr
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@chartdate,@seq_num,@result_name,@result_value)
 SET
   subject_id = trim(@subject_id),
   chartdate = trim(@chartdate),
   seq_num = trim(@seq_num),
   result_name = trim(@result_name),
   result_value = trim(@result_value);

DROP TABLE IF EXISTS outputevents;
CREATE TABLE outputevents (	-- rows=4450049
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000094, 29999828]
   stay_id INT NOT NULL,	-- range: [30000153, 39999810]
   caregiver_id INT,
   charttime DATETIME NOT NULL,
   storetime DATETIME NOT NULL,
   itemid MEDIUMINT NOT NULL,	-- range: [226557, 229414]
   value FLOAT NOT NULL,
   valueuom VARCHAR(255) NOT NULL	-- max length=2
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'outputevents.csv' INTO TABLE outputevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@caregiver_id,@charttime,@storetime,@itemid,@value,@valueuom)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
   caregiver_id = IF(@caregiver_id='', NULL, trim(@caregiver_id)),
   charttime = trim(@charttime),
   storetime = trim(@storetime),
   itemid = trim(@itemid),
   value = trim(@value),
   valueuom = trim(@valueuom);

DROP TABLE IF EXISTS patients;
CREATE TABLE patients (	-- rows=315460
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   gender VARCHAR(255) NOT NULL,	-- max length=1
   anchor_age TINYINT NOT NULL,	-- range: [18, 91]
   anchor_year SMALLINT NOT NULL,	-- range: [2110, 2208]
   anchor_year_group VARCHAR(255) NOT NULL,	-- max length=11
   dod DATE)
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'patients.csv' INTO TABLE patients
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@gender,@anchor_age,@anchor_year,@anchor_year_group,@dod)
 SET
   subject_id = trim(@subject_id),
   gender = trim(@gender),
   anchor_age = trim(@anchor_age),
   anchor_year = trim(@anchor_year),
   anchor_year_group = trim(@anchor_year_group),
   dod = IF(@dod='', NULL, trim(@dod));

DROP TABLE IF EXISTS pharmacy;
CREATE TABLE pharmacy (	-- rows=14291703
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000019, 29999928]
   pharmacy_id INT NOT NULL,	-- range: [12, 99999992]
   poe_id VARCHAR(255),	-- max length=14
   starttime DATETIME,
   stoptime DATETIME,
   medication VARCHAR(255),	-- max length=84
   proc_type VARCHAR(255) NOT NULL,	-- max length=21
   status VARCHAR(255) NOT NULL,	-- max length=36
   entertime DATETIME NOT NULL,
   verifiedtime DATETIME,
   route VARCHAR(255),	-- max length=28
   frequency VARCHAR(255),	-- max length=25
   disp_sched VARCHAR(255),	-- max length=84
   infusion_type VARCHAR(255),	-- max length=2
   sliding_scale VARCHAR(255),	-- max length=1
   lockout_interval VARCHAR(255),	-- max length=43
   basal_rate FLOAT,
   one_hr_max VARCHAR(255),	-- max length=6
   doses_per_24_hrs TINYINT,	-- range: [0, 70]
   duration FLOAT,
   duration_interval VARCHAR(255),	-- max length=7
   expiration_value SMALLINT,	-- range: [0, 365]
   expiration_unit VARCHAR(255),	-- max length=14
   expirationdate DATETIME,
   dispensation VARCHAR(255),	-- max length=28
   fill_quantity VARCHAR(255)	-- max length=8
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'pharmacy.csv' INTO TABLE pharmacy
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@pharmacy_id,@poe_id,@starttime,@stoptime,@medication,@proc_type,@status,@entertime,@verifiedtime,@route,@frequency,@disp_sched,@infusion_type,@sliding_scale,@lockout_interval,@basal_rate,@one_hr_max,@doses_per_24_hrs,@duration,@duration_interval,@expiration_value,@expiration_unit,@expirationdate,@dispensation,@fill_quantity)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   pharmacy_id = trim(@pharmacy_id),
   poe_id = IF(@poe_id='', NULL, trim(@poe_id)),
   starttime = IF(@starttime='', NULL, trim(@starttime)),
   stoptime = IF(@stoptime='', NULL, trim(@stoptime)),
   medication = IF(@medication='', NULL, trim(@medication)),
   proc_type = trim(@proc_type),
   status = trim(@status),
   entertime = trim(@entertime),
   verifiedtime = IF(@verifiedtime='', NULL, trim(@verifiedtime)),
   route = IF(@route='', NULL, trim(@route)),
   frequency = IF(@frequency='', NULL, trim(@frequency)),
   disp_sched = IF(@disp_sched='', NULL, trim(@disp_sched)),
   infusion_type = IF(@infusion_type='', NULL, trim(@infusion_type)),
   sliding_scale = IF(@sliding_scale='', NULL, trim(@sliding_scale)),
   lockout_interval = IF(@lockout_interval='', NULL, trim(@lockout_interval)),
   basal_rate = IF(@basal_rate='', NULL, trim(@basal_rate)),
   one_hr_max = IF(@one_hr_max='', NULL, trim(@one_hr_max)),
   doses_per_24_hrs = IF(@doses_per_24_hrs='', NULL, trim(@doses_per_24_hrs)),
   duration = IF(@duration='', NULL, trim(@duration)),
   duration_interval = IF(@duration_interval='', NULL, trim(@duration_interval)),
   expiration_value = IF(@expiration_value='', NULL, trim(@expiration_value)),
   expiration_unit = IF(@expiration_unit='', NULL, trim(@expiration_unit)),
   expirationdate = IF(@expirationdate='', NULL, trim(@expirationdate)),
   dispensation = IF(@dispensation='', NULL, trim(@dispensation)),
   fill_quantity = IF(@fill_quantity='', NULL, trim(@fill_quantity));

DROP TABLE IF EXISTS poe;
CREATE TABLE poe (	-- rows=41427803
   poe_id VARCHAR(255) NOT NULL,	-- max length=14
   poe_seq SMALLINT NOT NULL,	-- range: [2, 20081]
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000019, 29999928]
   ordertime DATETIME NOT NULL,
   order_type VARCHAR(255) NOT NULL,	-- max length=13
   order_subtype VARCHAR(255),	-- max length=48
   transaction_type VARCHAR(255) NOT NULL,	-- max length=6
   discontinue_of_poe_id VARCHAR(255),	-- max length=14
   discontinued_by_poe_id VARCHAR(255),	-- max length=14
   order_provider_id VARCHAR(255),
   order_status VARCHAR(255) NOT NULL	-- max length=8
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'poe.csv' INTO TABLE poe
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@poe_id,@poe_seq,@subject_id,@hadm_id,@ordertime,@order_type,@order_subtype,@transaction_type,@discontinue_of_poe_id,@discontinued_by_poe_id,@order_provider_id,@order_status)
 SET
   poe_id = trim(@poe_id),
   poe_seq = trim(@poe_seq),
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   ordertime = trim(@ordertime),
   order_type = trim(@order_type),
   order_subtype = IF(@order_subtype='', NULL, trim(@order_subtype)),
   transaction_type = trim(@transaction_type),
   discontinue_of_poe_id = IF(@discontinue_of_poe_id='', NULL, trim(@discontinue_of_poe_id)),
   discontinued_by_poe_id = IF(@discontinued_by_poe_id='', NULL, trim(@discontinued_by_poe_id)),
   order_provider_id = IF(@order_provider_id='', NULL, trim(@order_provider_id)),
   order_status = trim(@order_status);

DROP TABLE IF EXISTS poe_detail;
CREATE TABLE poe_detail (	-- rows=3174971
   poe_id VARCHAR(255) NOT NULL,	-- max length=14
   poe_seq SMALLINT NOT NULL,	-- range: [2, 20081]
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   field_name VARCHAR(255) NOT NULL,	-- max length=19
   field_value VARCHAR(255) NOT NULL	-- max length=54
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'poe_detail.csv' INTO TABLE poe_detail
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@poe_id,@poe_seq,@subject_id,@field_name,@field_value)
 SET
   poe_id = trim(@poe_id),
   poe_seq = trim(@poe_seq),
   subject_id = trim(@subject_id),
   field_name = trim(@field_name),
   field_value = trim(@field_value);

DROP TABLE IF EXISTS prescriptions;
CREATE TABLE prescriptions (	-- rows=16219412
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000019, 29999928]
   pharmacy_id INT NOT NULL,	-- range: [12, 99999992]
   poe_id VARCHAR(255),	-- max length=14
   poe_seq SMALLINT,	-- range: [2, 20078]
   order_provider_id VARCHAR(255),
   starttime DATETIME,
   stoptime DATETIME,
   drug_type VARCHAR(255) NOT NULL,	-- max length=8
   drug VARCHAR(255),	-- max length=84
   formulary_drug_cd VARCHAR(255),	-- max length=17
   gsn TEXT,	-- max length=223
   ndc VARCHAR(255),	-- max length=11
   prod_strength TEXT,	-- max length=112
   form_rx VARCHAR(255),	-- max length=9
   dose_val_rx VARCHAR(255),	-- max length=44
   dose_unit_rx VARCHAR(255),	-- max length=32
   form_val_disp VARCHAR(255),	-- max length=22
   form_unit_disp VARCHAR(255),	-- max length=19
   doses_per_24_hrs TINYINT,	-- range: [0, 70]
   route VARCHAR(255)	-- max length=28
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'prescriptions.csv' INTO TABLE prescriptions
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@pharmacy_id,@poe_id,@poe_seq,@order_provider_id,@starttime,@stoptime,@drug_type,@drug,@formulary_drug_cd,@gsn,@ndc,@prod_strength,@form_rx,@dose_val_rx,@dose_unit_rx,@form_val_disp,@form_unit_disp,@doses_per_24_hrs,@route)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   pharmacy_id = trim(@pharmacy_id),
   poe_id = IF(@poe_id='', NULL, trim(@poe_id)),
   poe_seq = IF(@poe_seq='', NULL, trim(@poe_seq)),
   order_provider_id = IF(@order_provider_id='', NULL, trim(@order_provider_id)),
   starttime = IF(@starttime='', NULL, trim(@starttime)),
   stoptime = IF(@stoptime='', NULL, trim(@stoptime)),
   drug_type = trim(@drug_type),
   drug = IF(@drug='', NULL, trim(@drug)),
   formulary_drug_cd = IF(@formulary_drug_cd='', NULL, trim(@formulary_drug_cd)),
   gsn = IF(@gsn='', NULL, trim(@gsn)),
   ndc = IF(@ndc='', NULL, trim(@ndc)),
   prod_strength = IF(@prod_strength='', NULL, trim(@prod_strength)),
   form_rx = IF(@form_rx='', NULL, trim(@form_rx)),
   dose_val_rx = IF(@dose_val_rx='', NULL, trim(@dose_val_rx)),
   dose_unit_rx = IF(@dose_unit_rx='', NULL, trim(@dose_unit_rx)),
   form_val_disp = IF(@form_val_disp='', NULL, trim(@form_val_disp)),
   form_unit_disp = IF(@form_unit_disp='', NULL, trim(@form_unit_disp)),
   doses_per_24_hrs = IF(@doses_per_24_hrs='', NULL, trim(@doses_per_24_hrs)),
   route = IF(@route='', NULL, trim(@route));

DROP TABLE IF EXISTS procedureevents;
CREATE TABLE procedureevents (	-- rows=731788
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000094, 29999828]
   stay_id INT NOT NULL,	-- range: [30000153, 39999810]
   caregiver_id INT,
   starttime DATETIME NOT NULL,
   endtime DATETIME NOT NULL,
   storetime DATETIME NOT NULL,
   itemid MEDIUMINT NOT NULL,	-- range: [221214, 229755]
   value FLOAT NOT NULL,
   valueuom VARCHAR(255) NOT NULL,	-- max length=4
   location VARCHAR(255),	-- max length=24
   locationcategory VARCHAR(255),	-- max length=19
   orderid INT NOT NULL,	-- range: [20, 9999994]
   linkorderid INT NOT NULL,	-- range: [20, 9999994]
   ordercategoryname VARCHAR(255) NOT NULL,	-- max length=21
   ordercategorydescription VARCHAR(255) NOT NULL,	-- max length=17
   patientweight FLOAT NOT NULL,
   isopenbag BOOLEAN NOT NULL,	-- range: [0, 1]
   continueinnextdept BOOLEAN NOT NULL,	-- range: [0, 1]
   statusdescription VARCHAR(255) NOT NULL,	-- max length=15
   originalamount FLOAT NOT NULL,
   originalrate BOOLEAN NOT NULL	-- range: [0, 1]
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'procedureevents.csv' INTO TABLE procedureevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@caregiver_id,@starttime,@endtime,@storetime,@itemid,@value,@valueuom,@location,@locationcategory,@orderid,@linkorderid,@ordercategoryname,@ordercategorydescription,@patientweight,@isopenbag,@continueinnextdept,@statusdescription,@originalamount,@originalrate)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
   caregiver_id = IF(@caregiver_id='', NULL, trim(@caregiver_id)),
   starttime = trim(@starttime),
   endtime = trim(@endtime),
   storetime = trim(@storetime),
   itemid = trim(@itemid),
   value = trim(@value),
   valueuom = trim(@valueuom),
   location = IF(@location='', NULL, trim(@location)),
   locationcategory = IF(@locationcategory='', NULL, trim(@locationcategory)),
   orderid = trim(@orderid),
   linkorderid = trim(@linkorderid),
   ordercategoryname = trim(@ordercategoryname),
   ordercategorydescription = trim(@ordercategorydescription),
   patientweight = trim(@patientweight),
   isopenbag = trim(@isopenbag),
   continueinnextdept = trim(@continueinnextdept),
   statusdescription = trim(@statusdescription),
   originalamount = trim(@originalamount),
   originalrate = trim(@originalrate);

DROP TABLE IF EXISTS procedures_icd;
CREATE TABLE procedures_icd (	-- rows=704124
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000041, 29999828]
   seq_num TINYINT NOT NULL,	-- range: [1, 41]
   chartdate DATE NOT NULL,
   icd_code VARCHAR(255) NOT NULL,	-- max length=7
   icd_version TINYINT NOT NULL	-- range: [9, 10]
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'procedures_icd.csv' INTO TABLE procedures_icd
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@seq_num,@chartdate,@icd_code,@icd_version)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   seq_num = trim(@seq_num),
   chartdate = trim(@chartdate),
   icd_code = trim(@icd_code),
   icd_version = trim(@icd_version);

DROP TABLE IF EXISTS provider;
CREATE TABLE provider (	-- rows=454324
   provider_id VARCHAR(255) NOT NULL -- max length=6
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'provider.csv' INTO TABLE provider
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@provider_id)
 SET
   provider_id = trim(@provider_id);

DROP TABLE IF EXISTS services;
CREATE TABLE services (	-- rows=492967
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT NOT NULL,	-- range: [20000019, 29999928]
   transfertime DATETIME NOT NULL,
   prev_service VARCHAR(255),	-- max length=5
   curr_service VARCHAR(255) NOT NULL	-- max length=5
  )
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'services.csv' INTO TABLE services
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@transfertime,@prev_service,@curr_service)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   transfertime = trim(@transfertime),
   prev_service = IF(@prev_service='', NULL, trim(@prev_service)),
   curr_service = trim(@curr_service);

DROP TABLE IF EXISTS transfers;
CREATE TABLE transfers (	-- rows=1991704
   subject_id INT NOT NULL,	-- range: [10000032, 19999987]
   hadm_id INT,	-- range: [20000019, 29999928]
   transfer_id INT NOT NULL,	-- range: [30000000, 39999980]
   eventtype VARCHAR(255) NOT NULL,	-- max length=9
   careunit VARCHAR(255),	-- max length=48
   intime DATETIME NOT NULL,
   outtime DATETIME)
  CHARACTER SET = UTF8MB4;

LOAD DATA LOCAL INFILE 'transfers.csv' INTO TABLE transfers
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@transfer_id,@eventtype,@careunit,@intime,@outtime)
 SET
   subject_id = trim(@subject_id),
   hadm_id = IF(@hadm_id='', NULL, trim(@hadm_id)),
   transfer_id = trim(@transfer_id),
   eventtype = trim(@eventtype),
   careunit = IF(@careunit='', NULL, trim(@careunit)),
   intime = trim(@intime),
   outtime = IF(@outtime='', NULL, trim(@outtime));

