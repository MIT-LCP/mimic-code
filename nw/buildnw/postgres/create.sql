-------------------------------------------
-- Create the tables and NW schema --
-------------------------------------------

----------------------
-- Creating schemas --
----------------------

DROP SCHEMA IF EXISTS nw_hosp CASCADE;
CREATE SCHEMA nw_hosp;
DROP SCHEMA IF EXISTS nw_icu CASCADE;
CREATE SCHEMA nw_icu;

---------------------
-- Creating tables --
---------------------

-- hosp schema

DROP TABLE IF EXISTS nw_hosp.admissions;
CREATE TABLE nw_hosp.admissions (
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER NOT NULL,
    admittime TIMESTAMP NOT NULL,
    dischtime TIMESTAMP,
    deathtime TIMESTAMP,
    admission_type VARCHAR(40), 
    admit_provider_id VARCHAR(10),
    admission_location VARCHAR(60),
    discharge_location VARCHAR(255), 
    insurance VARCHAR(255),
    language VARCHAR(25),
    marital_status VARCHAR(30),
    race VARCHAR(80),
    edregtime TIMESTAMP,
    edouttime TIMESTAMP,
    hospital_expire_flag SMALLINT
);

DROP TABLE IF EXISTS nw_hosp.patients;
CREATE TABLE nw_hosp.patients (
    subject_id INTEGER NOT NULL,
    gender CHAR(1) NOT NULL,
    anchor_age SMALLINT,
    anchor_year SMALLINT NOT NULL,
    anchor_year_group VARCHAR(20) NOT NULL,
    dod DATE
);

DROP TABLE IF EXISTS nw_hosp.d_icd_diagnoses;
CREATE TABLE nw_hosp.d_icd_diagnoses (
    icd_code CHAR(7) NOT NULL,
    icd_version SMALLINT NOT NULL,
    long_title VARCHAR(255)
);

DROP TABLE IF EXISTS nw_hosp.diagnoses_icd;
CREATE TABLE nw_hosp.diagnoses_icd (
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER NOT NULL,
    seq_num INTEGER NOT NULL,
    icd_code CHAR(7),
    icd_version SMALLINT
);

DROP TABLE IF EXISTS nw_hosp.d_labitems;
CREATE TABLE nw_hosp.d_labitems (
    itemid INTEGER NOT NULL,
    label VARCHAR(50),
    fluid VARCHAR(50),
    category VARCHAR(50)
);

DROP TABLE IF EXISTS nw_hosp.labevents;
CREATE TABLE nw_hosp.labevents (
    labevent_id INTEGER NOT NULL,
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER,
    specimen_id INTEGER, 
    itemid INTEGER NOT NULL,
    order_provider_id VARCHAR(10),
    charttime TIMESTAMP(0),
    storetime TIMESTAMP(0),
    value VARCHAR(200),
    valuenum DOUBLE PRECISION,
    valueuom VARCHAR(20),
    ref_range_lower DOUBLE PRECISION,
    ref_range_upper DOUBLE PRECISION,
    flag VARCHAR(10),
    priority VARCHAR(7),
    comments TEXT
);

DROP TABLE IF EXISTS nw_hosp.prescriptions;
CREATE TABLE nw_hosp.prescriptions (
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER NOT NULL,
    pharmacy_id INTEGER NOT NULL,
    poe_id VARCHAR(25),
    poe_seq INTEGER,
    order_provider_id VARCHAR(10),
    starttime TIMESTAMP(3),
    stoptime TIMESTAMP(3),
    drug_type VARCHAR(100),
    drug VARCHAR(255) NOT NULL,
    formulary_drug_cd VARCHAR(50),
    gsn VARCHAR(255),
    ndc VARCHAR(25),
    prod_strength VARCHAR(255),
    form_rx VARCHAR(25),
    dose_val_rx VARCHAR(100),
    dose_unit_rx VARCHAR(50),
    form_val_disp VARCHAR(255), 
    form_unit_disp VARCHAR(65), 
    doses_per_24_hrs REAL,
    route VARCHAR(50)

);

DROP TABLE IF EXISTS nw_hosp.emar;
CREATE TABLE nw_hosp.emar
(
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER,
    emar_id VARCHAR(25) NOT NULL,
    emar_seq INTEGER NOT NULL,
    poe_id VARCHAR(25) NOT NULL,
    pharmacy_id INTEGER,
    enter_provider_id VARCHAR(10),
    charttime TIMESTAMP NOT NULL,
    medication TEXT,
    event_txt VARCHAR(100),
    scheduletime TIMESTAMP,
    storetime TIMESTAMP NOT NULL
);

-- icu schema

DROP TABLE IF EXISTS nw_icu.icustays;
CREATE TABLE nw_icu.icustays (
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER NOT NULL,
    stay_id INTEGER NOT NULL,
    first_careunit VARCHAR(255),
    last_careunit VARCHAR(255),
    intime TIMESTAMP,
    outtime TIMESTAMP,
    los FLOAT
);

DROP TABLE IF EXISTS nw_icu.d_items;
CREATE TABLE nw_icu.d_items (
    itemid INTEGER NOT NULL,
    label VARCHAR(200) NOT NULL, 
    abbreviation VARCHAR(50),
    linksto VARCHAR(30) NOT NULL,
    category VARCHAR(50),
    unitname VARCHAR(50),
    param_type VARCHAR(20) NOT NULL,
    lownormalvalue FLOAT,
    highnormalvalue FLOAT
);

DROP TABLE IF EXISTS nw_icu.chartevents;
CREATE TABLE nw_icu.chartevents (
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER NOT NULL,
    stay_id INTEGER NOT NULL,
    caregiver_id INTEGER,
    charttime TIMESTAMP NOT NULL,
    storetime TIMESTAMP,
    itemid INTEGER NOT NULL,
    value VARCHAR(200),
    valuenum FLOAT,
    valueuom VARCHAR(20),
    warning SMALLINT
);

DROP TABLE IF EXISTS nw_icu.procedureevents;
CREATE TABLE nw_icu.procedureevents (
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER NOT NULL,
    stay_id INTEGER NOT NULL,
    caregiver_id INTEGER,
    starttime TIMESTAMP NOT NULL,
    endtime TIMESTAMP, 
    storetime TIMESTAMP, 
    itemid INTEGER NOT NULL,
    value FLOAT,
    valueuom VARCHAR(20),
    location VARCHAR(100),
    locationcategory VARCHAR(50),
    orderid INTEGER,  
    linkorderid INTEGER,
    ordercategoryname VARCHAR(50),
    ordercategorydescription VARCHAR(30),
    patientweight FLOAT,
    isopenbag SMALLINT,
    continueinnextdept SMALLINT,
    statusdescription VARCHAR(30),
    originalamount FLOAT,
    originalrate FLOAT
);
