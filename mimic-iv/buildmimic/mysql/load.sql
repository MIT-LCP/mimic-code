-- csv2mysql with arguments:
--   -o
--   1-load-no-keys.sql
--   -e
--   
--   -u
--   -z
--   -p
--   admissions.csv
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
--   inputevents.csv
--   labevents.csv
--   microbiologyevents.csv
--   outputevents.csv
--   patients.csv
--   pharmacy.csv
--   poe.csv
--   poe_detail.csv
--   prescriptions.csv
--   procedureevents.csv
--   procedures_icd.csv
--   services.csv
--   transfers.csv

warnings

DROP TABLE IF EXISTS admissions;
CREATE TABLE admissions (	-- rows=524520
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   admittime DATETIME NOT NULL,
   dischtime DATETIME NOT NULL,
   deathtime DATETIME,
   admission_type VARCHAR(255) NOT NULL,	-- max=27
   admission_location VARCHAR(255),	-- max=38
   discharge_location VARCHAR(255),	-- max=28
   insurance VARCHAR(255) NOT NULL,	-- max=8
   language VARCHAR(255) NOT NULL,	-- max=7
   marital_status VARCHAR(255),	-- max=8
   race VARCHAR(255) NOT NULL,	-- max=29
   edregtime DATETIME,
   edouttime DATETIME,
   hospital_expire_flag BOOLEAN NOT NULL)
  CHARACTER SET = UTF8;

LOAD DATA LOCAL INFILE 'admissions.csv' INTO TABLE admissions
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@admittime,@dischtime,@deathtime,@admission_type,@admission_location,@discharge_location,@insurance,@language,@marital_status,@race,@edregtime,@edouttime,@hospital_expire_flag)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   admittime = trim(@admittime),
   dischtime = trim(@dischtime),
   deathtime = IF(@deathtime='', NULL, trim(@deathtime)),
   admission_type = trim(@admission_type),
   admission_location = IF(@admission_location='', NULL, trim(@admission_location)),
   discharge_location = IF(@discharge_location='', NULL, trim(@discharge_location)),
   insurance = trim(@insurance),
   language = trim(@language),
   marital_status = IF(@marital_status='', NULL, trim(@marital_status)),
   race = trim(@race),
   edregtime = IF(@edregtime='', NULL, trim(@edregtime)),
   edouttime = IF(@edouttime='', NULL, trim(@edouttime)),
   hospital_expire_flag = trim(@hospital_expire_flag);

DROP TABLE IF EXISTS chartevents;
CREATE TABLE chartevents (	-- rows=327363274
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   stay_id INT UNSIGNED NOT NULL,
   charttime DATETIME NOT NULL,
   storetime DATETIME,
   itemid MEDIUMINT UNSIGNED NOT NULL,
   value TEXT,	-- max=156
   valuenum FLOAT,
   valueuom VARCHAR(255),	-- max=17
   warning BOOLEAN NOT NULL)
  CHARACTER SET = UTF8
  PARTITION BY HASH(itemid) PARTITIONS 50;

LOAD DATA LOCAL INFILE 'chartevents.csv' INTO TABLE chartevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@charttime,@storetime,@itemid,@value,@valuenum,@valueuom,@warning)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
   charttime = trim(@charttime),
   storetime = IF(@storetime='', NULL, trim(@storetime)),
   itemid = trim(@itemid),
   value = IF(@value='', NULL, trim(@value)),
   valuenum = IF(@valuenum='', NULL, trim(@valuenum)),
   valueuom = IF(@valueuom='', NULL, trim(@valueuom)),
   warning = trim(@warning);

DROP TABLE IF EXISTS d_hcpcs;
CREATE TABLE d_hcpcs (	-- rows=89200
   code VARCHAR(255) NOT NULL,	-- max=5
   category TINYINT UNSIGNED,
   long_description TEXT,	-- max=1182
   short_description TEXT NOT NULL	-- max=165
  )
  CHARACTER SET = UTF8;

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
CREATE TABLE d_icd_diagnoses (	-- rows=86751
   icd_code VARCHAR(255) NOT NULL,	-- max=7
   icd_version TINYINT UNSIGNED NOT NULL,
   long_title TEXT NOT NULL	-- max=228
  )
  CHARACTER SET = UTF8;

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
CREATE TABLE d_icd_procedures (	-- rows=82763
   icd_code VARCHAR(255) NOT NULL,	-- max=7
   icd_version TINYINT UNSIGNED NOT NULL,
   long_title TEXT NOT NULL	-- max=163
  )
  CHARACTER SET = UTF8;

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
CREATE TABLE d_items (	-- rows=3835
   itemid MEDIUMINT UNSIGNED NOT NULL,
   label TEXT NOT NULL,	-- max=95
   abbreviation VARCHAR(255) NOT NULL,	-- max=50
   linksto VARCHAR(255) NOT NULL,	-- max=15
   category VARCHAR(255) NOT NULL,	-- max=27
   unitname VARCHAR(255),	-- max=19
   param_type VARCHAR(255) NOT NULL,	-- max=16
   lownormalvalue SMALLINT,
   highnormalvalue FLOAT)
  CHARACTER SET = UTF8;

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
CREATE TABLE d_labitems (	-- rows=1625
   itemid SMALLINT UNSIGNED NOT NULL,
   label VARCHAR(255),	-- max=42
   fluid VARCHAR(255) NOT NULL,	-- max=19
   category VARCHAR(255) NOT NULL	-- max=10
  )
  CHARACTER SET = UTF8;

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
CREATE TABLE datetimeevents (	-- rows=6999316
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   stay_id INT UNSIGNED NOT NULL,
   charttime DATETIME NOT NULL,
   storetime DATETIME NOT NULL,
   itemid MEDIUMINT UNSIGNED NOT NULL,
   value DATETIME NOT NULL,
   valueuom VARCHAR(255) NOT NULL,	-- max=13
   warning BOOLEAN NOT NULL)
  CHARACTER SET = UTF8;

LOAD DATA LOCAL INFILE 'datetimeevents.csv' INTO TABLE datetimeevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@charttime,@storetime,@itemid,@value,@valueuom,@warning)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
   charttime = trim(@charttime),
   storetime = trim(@storetime),
   itemid = trim(@itemid),
   value = trim(@value),
   valueuom = trim(@valueuom),
   warning = trim(@warning);

DROP TABLE IF EXISTS diagnoses_icd;
CREATE TABLE diagnoses_icd (	-- rows=4677924
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   seq_num TINYINT UNSIGNED NOT NULL,
   icd_code VARCHAR(255) NOT NULL,	-- max=7
   icd_version TINYINT UNSIGNED NOT NULL)
  CHARACTER SET = UTF8;

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
CREATE TABLE drgcodes (	-- rows=1168135
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   drg_type VARCHAR(255) NOT NULL,	-- max=4
   drg_code VARCHAR(255) NOT NULL,	-- max=4
   description TEXT,	-- max=88
   drg_severity TINYINT UNSIGNED,
   drg_mortality TINYINT UNSIGNED)
  CHARACTER SET = UTF8;

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
   description = IF(@description='', NULL, trim(@description)),
   drg_severity = IF(@drg_severity='', NULL, trim(@drg_severity)),
   drg_mortality = IF(@drg_mortality='', NULL, trim(@drg_mortality));

DROP TABLE IF EXISTS emar;
CREATE TABLE emar (	-- rows=27590435
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED,
   emar_id VARCHAR(255) NOT NULL,	-- max=14
   emar_seq SMALLINT UNSIGNED NOT NULL,
   poe_id VARCHAR(255) NOT NULL,	-- max=14
   pharmacy_id INT UNSIGNED,
   charttime DATETIME NOT NULL,
   medication VARCHAR(255),	-- max=75
   event_txt VARCHAR(255),	-- max=48
   scheduletime DATETIME,
   storetime DATETIME NOT NULL)
  CHARACTER SET = UTF8;

LOAD DATA LOCAL INFILE 'emar.csv' INTO TABLE emar
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@emar_id,@emar_seq,@poe_id,@pharmacy_id,@charttime,@medication,@event_txt,@scheduletime,@storetime)
 SET
   subject_id = trim(@subject_id),
   hadm_id = IF(@hadm_id='', NULL, trim(@hadm_id)),
   emar_id = trim(@emar_id),
   emar_seq = trim(@emar_seq),
   poe_id = trim(@poe_id),
   pharmacy_id = IF(@pharmacy_id='', NULL, trim(@pharmacy_id)),
   charttime = trim(@charttime),
   medication = IF(@medication='', NULL, trim(@medication)),
   event_txt = IF(@event_txt='', NULL, trim(@event_txt)),
   scheduletime = IF(@scheduletime='', NULL, trim(@scheduletime)),
   storetime = trim(@storetime);

DROP TABLE IF EXISTS emar_detail;
CREATE TABLE emar_detail (	-- rows=56203135
   subject_id INT UNSIGNED NOT NULL,
   emar_id VARCHAR(255) NOT NULL,	-- max=14
   emar_seq SMALLINT UNSIGNED NOT NULL,
   parent_field_ordinal FLOAT,
   administration_type VARCHAR(255),	-- max=47
   pharmacy_id INT UNSIGNED,
   barcode_type VARCHAR(255),	-- max=4
   reason_for_no_barcode TEXT,	-- max=831
   complete_dose_not_given VARCHAR(255),	-- max=3
   dose_due VARCHAR(255),	-- max=51
   dose_due_unit VARCHAR(255),	-- max=26
   dose_given TEXT,	-- max=152
   dose_given_unit VARCHAR(255),	-- max=26
   will_remainder_of_dose_be_given VARCHAR(255),	-- max=3
   product_amount_given VARCHAR(255),	-- max=23
   product_unit VARCHAR(255),	-- max=13
   product_code VARCHAR(255),	-- max=19
   product_description TEXT,	-- max=179
   product_description_other TEXT,	-- max=97
   prior_infusion_rate VARCHAR(255),	-- max=14
   infusion_rate VARCHAR(255),	-- max=14
   infusion_rate_adjustment VARCHAR(255),	-- max=31
   infusion_rate_adjustment_amount VARCHAR(255),	-- max=23
   infusion_rate_unit VARCHAR(255),	-- max=19
   route VARCHAR(255),	-- max=6
   infusion_complete VARCHAR(255),	-- max=1
   completion_interval VARCHAR(255),	-- max=23
   new_iv_bag_hung VARCHAR(255),	-- max=1
   continued_infusion_in_other_location VARCHAR(255),	-- max=1
   restart_interval VARCHAR(255),	-- max=19
   side VARCHAR(255),	-- max=6
   site TEXT,	-- max=236
   non_formulary_visual_verification VARCHAR(255)	-- max=1
  )
  CHARACTER SET = UTF8;

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
CREATE TABLE hcpcsevents (	-- rows=144858
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   chartdate DATETIME NOT NULL,
   hcpcs_cd VARCHAR(255) NOT NULL,	-- max=5
   seq_num TINYINT UNSIGNED NOT NULL,
   short_description TEXT NOT NULL	-- max=165
  )
  CHARACTER SET = UTF8;

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
CREATE TABLE icustays (	-- rows=69619
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   stay_id INT UNSIGNED NOT NULL,
   first_careunit VARCHAR(255) NOT NULL,	-- max=48
   last_careunit VARCHAR(255) NOT NULL,	-- max=48
   intime DATETIME NOT NULL,
   outtime DATETIME NOT NULL,
   los FLOAT NOT NULL)
  CHARACTER SET = UTF8;

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
CREATE TABLE ingredientevents (	-- rows=8869715
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   stay_id INT UNSIGNED NOT NULL,
   starttime DATETIME NOT NULL,
   endtime DATETIME NOT NULL,
   storetime DATETIME NOT NULL,
   itemid MEDIUMINT UNSIGNED NOT NULL,
   amount FLOAT NOT NULL,
   amountuom VARCHAR(255) NOT NULL,	-- max=19
   rate FLOAT,
   rateuom VARCHAR(255),	-- max=13
   orderid MEDIUMINT UNSIGNED NOT NULL,
   linkorderid MEDIUMINT UNSIGNED NOT NULL,
   statusdescription VARCHAR(255) NOT NULL,	-- max=15
   originalamount FLOAT NOT NULL,
   originalrate FLOAT NOT NULL)
  CHARACTER SET = UTF8;

LOAD DATA LOCAL INFILE 'ingredientevents.csv' INTO TABLE ingredientevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@starttime,@endtime,@storetime,@itemid,@amount,@amountuom,@rate,@rateuom,@orderid,@linkorderid,@statusdescription,@originalamount,@originalrate)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
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
CREATE TABLE inputevents (	-- rows=8869715
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   stay_id INT UNSIGNED NOT NULL,
   starttime DATETIME NOT NULL,
   endtime DATETIME NOT NULL,
   storetime DATETIME NOT NULL,
   itemid MEDIUMINT UNSIGNED NOT NULL,
   amount FLOAT NOT NULL,
   amountuom VARCHAR(255) NOT NULL,	-- max=19
   rate FLOAT,
   rateuom VARCHAR(255),	-- max=13
   orderid MEDIUMINT UNSIGNED NOT NULL,
   linkorderid MEDIUMINT UNSIGNED NOT NULL,
   ordercategoryname VARCHAR(255) NOT NULL,	-- max=24
   secondaryordercategoryname VARCHAR(255),	-- max=24
   ordercomponenttypedescription VARCHAR(255) NOT NULL,	-- max=57
   ordercategorydescription VARCHAR(255) NOT NULL,	-- max=14
   patientweight FLOAT NOT NULL,
   totalamount FLOAT,
   totalamountuom VARCHAR(255),	-- max=2
   isopenbag BOOLEAN NOT NULL,
   continueinnextdept BOOLEAN NOT NULL,
   statusdescription VARCHAR(255) NOT NULL,	-- max=15
   originalamount FLOAT NOT NULL,
   originalrate FLOAT NOT NULL)
  CHARACTER SET = UTF8;

LOAD DATA LOCAL INFILE 'inputevents.csv' INTO TABLE inputevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@starttime,@endtime,@storetime,@itemid,@amount,@amountuom,@rate,@rateuom,@orderid,@linkorderid,@ordercategoryname,@secondaryordercategoryname,@ordercomponenttypedescription,@ordercategorydescription,@patientweight,@totalamount,@totalamountuom,@isopenbag,@continueinnextdept,@cancelreason,@statusdescription,@originalamount,@originalrate)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
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
   cancelreason = trim(@cancelreason),
   statusdescription = trim(@statusdescription),
   originalamount = trim(@originalamount),
   originalrate = trim(@originalrate);

DROP TABLE IF EXISTS labevents;
CREATE TABLE labevents (	-- rows=122289828
   labevent_id INT UNSIGNED NOT NULL,
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED,
   specimen_id INT UNSIGNED NOT NULL,
   itemid SMALLINT UNSIGNED NOT NULL,
   charttime DATETIME NOT NULL,
   storetime DATETIME,
   value TEXT,	-- max=168
   valuenum FLOAT,
   valueuom VARCHAR(255),	-- max=15
   ref_range_lower FLOAT,
   ref_range_upper FLOAT,
   flag VARCHAR(255),	-- max=8
   priority VARCHAR(255),	-- max=7
   comments TEXT	-- max=615
  )
  CHARACTER SET = UTF8
  PARTITION BY HASH(itemid) PARTITIONS 50;

LOAD DATA LOCAL INFILE 'labevents.csv' INTO TABLE labevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@labevent_id,@subject_id,@hadm_id,@specimen_id,@itemid,@charttime,@storetime,@value,@valuenum,@valueuom,@ref_range_lower,@ref_range_upper,@flag,@priority,@comments)
 SET
   labevent_id = trim(@labevent_id),
   subject_id = trim(@subject_id),
   hadm_id = IF(@hadm_id='', NULL, trim(@hadm_id)),
   specimen_id = trim(@specimen_id),
   itemid = trim(@itemid),
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
CREATE TABLE microbiologyevents (	-- rows=1026113
   microevent_id MEDIUMINT UNSIGNED NOT NULL,
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED,
   micro_specimen_id MEDIUMINT UNSIGNED NOT NULL,
   chartdate DATETIME NOT NULL,
   charttime DATETIME,
   spec_itemid MEDIUMINT UNSIGNED NOT NULL,
   spec_type_desc VARCHAR(255) NOT NULL,	-- max=56
   test_seq TINYINT UNSIGNED NOT NULL,
   storedate DATETIME,
   storetime DATETIME,
   test_itemid MEDIUMINT UNSIGNED NOT NULL,
   test_name VARCHAR(255) NOT NULL,	-- max=66
   org_itemid MEDIUMINT UNSIGNED,
   org_name VARCHAR(255),	-- max=70
   isolate_num TINYINT UNSIGNED,
   quantity VARCHAR(255),	-- max=15
   ab_itemid MEDIUMINT UNSIGNED,
   ab_name VARCHAR(255),	-- max=20
   dilution_text VARCHAR(255),	-- max=6
   dilution_comparison VARCHAR(255),	-- max=2
   dilution_value FLOAT,
   interpretation VARCHAR(255),	-- max=1
   comments VARCHAR(255)	-- max=0
  )
  CHARACTER SET = UTF8;

LOAD DATA LOCAL INFILE 'microbiologyevents.csv' INTO TABLE microbiologyevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@microevent_id,@subject_id,@hadm_id,@micro_specimen_id,@chartdate,@charttime,@spec_itemid,@spec_type_desc,@test_seq,@storedate,@storetime,@test_itemid,@test_name,@org_itemid,@org_name,@isolate_num,@quantity,@ab_itemid,@ab_name,@dilution_text,@dilution_comparison,@dilution_value,@interpretation,@comments)
 SET
   microevent_id = trim(@microevent_id),
   subject_id = trim(@subject_id),
   hadm_id = IF(@hadm_id='', NULL, trim(@hadm_id)),
   micro_specimen_id = trim(@micro_specimen_id),
   chartdate = trim(@chartdate),
   charttime = IF(@charttime='', NULL, trim(@charttime)),
   spec_itemid = trim(@spec_itemid),
   spec_type_desc = trim(@spec_type_desc),
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

DROP TABLE IF EXISTS mimic_hosp.omr;
CREATE TABLE mimic_hosp.omr (
    subject_id INT UNSIGNED NOT NULL,
    chartdate DATETIME NOT NULL,
    seq_num SMALLINT UNSIGNED NOT NULL,
    result_name VARCHAR(255) NOT NULL,
    result_value VARCHAR(255) NOT NULL
  )
  CHARACTER SET = UTF8;

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
CREATE TABLE outputevents (	-- rows=4248828
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   stay_id INT UNSIGNED NOT NULL,
   charttime DATETIME NOT NULL,
   storetime DATETIME NOT NULL,
   itemid MEDIUMINT UNSIGNED NOT NULL,
   value FLOAT NOT NULL,
   valueuom VARCHAR(255) NOT NULL	-- max=2
  )
  CHARACTER SET = UTF8;

LOAD DATA LOCAL INFILE 'outputevents.csv' INTO TABLE outputevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@charttime,@storetime,@itemid,@value,@valueuom)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
   charttime = trim(@charttime),
   storetime = trim(@storetime),
   itemid = trim(@itemid),
   value = trim(@value),
   valueuom = trim(@valueuom);

DROP TABLE IF EXISTS patients;
CREATE TABLE patients (	-- rows=383220
   subject_id INT UNSIGNED NOT NULL,
   gender VARCHAR(255) NOT NULL,	-- max=1
   anchor_age TINYINT UNSIGNED NOT NULL,
   anchor_year SMALLINT UNSIGNED NOT NULL,
   anchor_year_group VARCHAR(255) NOT NULL,	-- max=11
   dod VARCHAR(255)	-- max=0
  )
  CHARACTER SET = UTF8;

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
CREATE TABLE pharmacy (	-- rows=14747759
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   pharmacy_id INT UNSIGNED NOT NULL,
   poe_id VARCHAR(255),	-- max=14
   starttime DATETIME,
   stoptime DATETIME,
   medication VARCHAR(255),	-- max=84
   proc_type VARCHAR(255) NOT NULL,	-- max=21
   status VARCHAR(255) NOT NULL,	-- max=36
   entertime DATETIME NOT NULL,
   verifiedtime DATETIME,
   route VARCHAR(255),	-- max=28
   frequency VARCHAR(255),	-- max=25
   disp_sched VARCHAR(255),	-- max=84
   infusion_type VARCHAR(255),	-- max=2
   sliding_scale VARCHAR(255),	-- max=1
   lockout_interval VARCHAR(255),	-- max=43
   basal_rate FLOAT,
   one_hr_max VARCHAR(255),	-- max=6
   doses_per_24_hrs TINYINT UNSIGNED,
   duration FLOAT,
   duration_interval VARCHAR(255),	-- max=7
   expiration_value SMALLINT UNSIGNED,
   expiration_unit VARCHAR(255),	-- max=14
   expirationdate DATETIME,
   dispensation VARCHAR(255),	-- max=28
   fill_quantity VARCHAR(255)	-- max=16
  )
  CHARACTER SET = UTF8;

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
CREATE TABLE poe (	-- rows=42526844
   poe_id VARCHAR(255) NOT NULL,	-- max=14
   poe_seq SMALLINT UNSIGNED NOT NULL,
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   ordertime DATETIME NOT NULL,
   order_type VARCHAR(255) NOT NULL,	-- max=13
   order_subtype VARCHAR(255),	-- max=48
   transaction_type VARCHAR(255) NOT NULL,	-- max=6
   discontinue_of_poe_id VARCHAR(255),	-- max=14
   discontinued_by_poe_id VARCHAR(255),	-- max=14
   order_status VARCHAR(255)	-- max=8
  )
  CHARACTER SET = UTF8;

LOAD DATA LOCAL INFILE 'poe.csv' INTO TABLE poe
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@poe_id,@poe_seq,@subject_id,@hadm_id,@ordertime,@order_type,@order_subtype,@transaction_type,@discontinue_of_poe_id,@discontinued_by_poe_id,@order_status)
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
   order_status = IF(@order_status='', NULL, trim(@order_status));

DROP TABLE IF EXISTS poe_detail;
CREATE TABLE poe_detail (	-- rows=3259644
   poe_id VARCHAR(255) NOT NULL,	-- max=14
   poe_seq SMALLINT UNSIGNED NOT NULL,
   subject_id INT UNSIGNED NOT NULL,
   field_name VARCHAR(255) NOT NULL,	-- max=19
   field_value VARCHAR(255) NOT NULL	-- max=54
  )
  CHARACTER SET = UTF8;

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
CREATE TABLE prescriptions (	-- rows=17021399
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   pharmacy_id INT UNSIGNED NOT NULL,
   poe_id  VARCHAR(25),
   poe_seq INT UNSIGNED,
   starttime DATETIME,
   stoptime DATETIME,
   drug_type VARCHAR(255) NOT NULL,	-- max=8
   drug VARCHAR(255),	-- max=84
   formulary_drug_cd VARCHAR(50),
   gsn TEXT,	-- max=223
   ndc VARCHAR(255),	-- max=11
   prod_strength TEXT,	-- max=112
   form_rx VARCHAR(255),	-- max=9
   dose_val_rx VARCHAR(255),	-- max=44
   dose_unit_rx VARCHAR(255),	-- max=32
   form_val_disp VARCHAR(255),	-- max=22
   form_unit_disp VARCHAR(255),	-- max=19
   doses_per_24_hrs TINYINT UNSIGNED,
   route VARCHAR(255)	-- max=28
  )
  CHARACTER SET = UTF8;

LOAD DATA LOCAL INFILE 'prescriptions.csv' INTO TABLE prescriptions
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@pharmacy_id,@poe_id,@poe_seq,@starttime,@stoptime,@drug_type,@drug,@formulary_drug_cd,@gsn,@ndc,@prod_strength,@form_rx,@dose_val_rx,@dose_unit_rx,@form_val_disp,@form_unit_disp,@doses_per_24_hrs,@route)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   pharmacy_id = trim(@pharmacy_id),
   poe_id = trim(@poe_id),
   poe_seq = trim(@poe_seq),
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
CREATE TABLE procedureevents (	-- rows=689846
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   stay_id INT UNSIGNED NOT NULL,
   starttime DATETIME NOT NULL,
   endtime DATETIME NOT NULL,
   storetime DATETIME NOT NULL,
   itemid MEDIUMINT UNSIGNED NOT NULL,
   value FLOAT NOT NULL,
   valueuom VARCHAR(255) NOT NULL,	-- max=4
   location VARCHAR(255),	-- max=24
   locationcategory VARCHAR(255),	-- max=19
   orderid MEDIUMINT UNSIGNED NOT NULL,
   linkorderid MEDIUMINT UNSIGNED NOT NULL,
   ordercategoryname VARCHAR(255) NOT NULL,	-- max=21
   ordercategorydescription VARCHAR(255) NOT NULL,	-- max=17
   patientweight FLOAT NOT NULL,
   isopenbag BOOLEAN NOT NULL,
   continueinnextdept BOOLEAN NOT NULL,
   statusdescription VARCHAR(255) NOT NULL,	-- max=15
   originalamount FLOAT NOT NULL,
   originalrate BOOLEAN NOT NULL)
  CHARACTER SET = UTF8;

LOAD DATA LOCAL INFILE 'procedureevents.csv' INTO TABLE procedureevents
   FIELDS TERMINATED BY ',' ESCAPED BY '' OPTIONALLY ENCLOSED BY '"'
   LINES TERMINATED BY '\n'
   IGNORE 1 LINES
   (@subject_id,@hadm_id,@stay_id,@starttime,@endtime,@storetime,@itemid,@value,@valueuom,@location,@locationcategory,@orderid,@linkorderid,@ordercategoryname,,@ordercategorydescription,@patientweight,@isopenbag,@continueinnextdept,@statusdescription)
 SET
   subject_id = trim(@subject_id),
   hadm_id = trim(@hadm_id),
   stay_id = trim(@stay_id),
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
CREATE TABLE procedures_icd (	-- rows=685414
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   seq_num TINYINT UNSIGNED NOT NULL,
   chartdate DATETIME NOT NULL,
   icd_code VARCHAR(255) NOT NULL,	-- max=7
   icd_version TINYINT UNSIGNED NOT NULL)
  CHARACTER SET = UTF8;

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

DROP TABLE IF EXISTS services;
CREATE TABLE services (	-- rows=563706
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED NOT NULL,
   transfertime DATETIME NOT NULL,
   prev_service VARCHAR(255),	-- max=5
   curr_service VARCHAR(255) NOT NULL	-- max=5
  )
  CHARACTER SET = UTF8;

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
CREATE TABLE transfers (	-- rows=2192963
   subject_id INT UNSIGNED NOT NULL,
   hadm_id INT UNSIGNED,
   transfer_id INT UNSIGNED NOT NULL,
   eventtype VARCHAR(255) NOT NULL,	-- max=9
   careunit VARCHAR(255),	-- max=48
   intime DATETIME NOT NULL,
   outtime DATETIME)
  CHARACTER SET = UTF8;

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

