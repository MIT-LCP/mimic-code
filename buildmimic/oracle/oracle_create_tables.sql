--------------------------------------------------------
--  File created - Friday-September-04-2015
--------------------------------------------------------

-- The below command defines the schema where all tables are created
ALTER SESSION SET CURRENT_SCHEMA = MIMICIII;

-- Restoring the default schema can be accomplished using the same command, replacing "MIMICIII" with your username.


--------------------------------------------------------
--  DDL for Table ADMISSIONS
--------------------------------------------------------

DROP TABLE ADMISSIONS;
CREATE TABLE ADMISSIONS (
    ROW_ID                      NUMBER(10,0) NOT NULL,
    SUBJECT_ID                  NUMBER(7,0) NOT NULL,
    HADM_ID                     NUMBER(7,0) NOT NULL,
    ADMITTIME                   DATE NOT NULL,
    DISCHTIME                   DATE NOT NULL,
    DEATHTIME                   DATE,
    ADMISSION_TYPE              VARCHAR2(25) NOT NULL,
    ADMISSION_LOCATION          VARCHAR2(25) NOT NULL,
    DISCHARGE_LOCATION          VARCHAR2(30) NOT NULL,
    INSURANCE                   VARCHAR2(255) NOT NULL,
    LANGUAGE                    VARCHAR2(4),
    RELIGION                    VARCHAR2(25),
    MARITAL_STATUS              VARCHAR2(25),
    ETHNICITY                   VARCHAR2(80) NOT NULL,
    EDREGTIME                   DATE,
    EDOUTTIME                   DATE,
    DIAGNOSIS                   VARCHAR2(200),
    HOSPITAL_EXPIRE_FLAG        NUMBER(1,0) NOT NULL,
    HAS_IOEVENTS_DATA           NUMBER(1,0) NOT NULL,
    HAS_CHARTEVENTS_DATA        NUMBER(1,0) NOT NULL,
    CONSTRAINT adm_rowid_pk PRIMARY KEY (ROW_ID),
    CONSTRAINT adm_hadm_unique UNIQUE (HADM_ID)
    );

--------------------------------------------------------
--  DDL for Table CALLOUT
--------------------------------------------------------

DROP TABLE CALLOUT;
CREATE TABLE CALLOUT (
    ROW_ID                  NUMBER(10,0) NOT NULL,
    SUBJECT_ID              NUMBER(7,0) NOT NULL,
    HADM_ID                 NUMBER(7,0) NOT NULL,
    SUBMIT_WARDID           NUMBER(5,0),
    SUBMIT_CAREUNIT         VARCHAR2(15),
    CURR_WARDID             NUMBER(5,0),
    CURR_CAREUNIT           VARCHAR2(15),
    CALLOUT_WARDID          NUMBER(5,0),
    CALLOUT_SERVICE         VARCHAR2(10) NOT NULL,
    REQUEST_TELE            NUMBER(3,0) NOT null,
    REQUEST_RESP            NUMBER(3,0) NOT null,
    REQUEST_CDIFF           NUMBER(3,0) NOT null,
    REQUEST_MRSA            NUMBER(3,0) NOT null,
    REQUEST_VRE             NUMBER(3,0) NOT null,
    CALLOUT_STATUS          VARCHAR2(20) NOT NULL,
    CALLOUT_OUTCOME         VARCHAR2(20) NOT NULL,
    DISCHARGE_WARDID        NUMBER(5,0),
    ACKNOWLEDGE_STATUS      VARCHAR2(20) NOT NULL,
    CREATETIME              DATE NOT NULL,
    UPDATETIME              DATE NOT NULL,
    ACKNOWLEDGETIME         DATE,
    OUTCOMETIME             DATE NOT NULL,
    FIRSTRESERVATIONTIME    DATE,
    CURRENTRESERVATIONTIME  DATE,
    CONSTRAINT callout_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table CAREGIVERS
--------------------------------------------------------

DROP TABLE CAREGIVERS;
CREATE TABLE CAREGIVERS (
    ROW_ID                  NUMBER(10,0) NOT NULL,
    CGID                    NUMBER(6,0) NOT NULL,
    LABEL                   VARCHAR2(10),
    DESCRIPTION             VARCHAR2(22),
    CONSTRAINT cg_rowid_pk  PRIMARY KEY (ROW_ID),
    CONSTRAINT cg_cgid_unique UNIQUE (CGID)
    );

--------------------------------------------------------
--  DDL for Table CHARTEVENTS
--------------------------------------------------------

DROP TABLE CHARTEVENTS;
CREATE TABLE CHARTEVENTS (
    ROW_ID                  NUMBER(10,0) NOT NULL,
    SUBJECT_ID              NUMBER(7,0) NOT NULL,
    HADM_ID                 NUMBER(7,0),
    ICUSTAY_ID              NUMBER(7,0),
    ITEMID                  NUMBER(7,0),
    CHARTTIME               DATE,
    STORETIME               DATE,
    CGID                    NUMBER(7,0),
    VALUE                   VARCHAR2(200 BYTE),
    VALUENUM                NUMBER,
    VALUEUOM                VARCHAR2(20 BYTE),
    WARNING                 NUMBER(1,0),
    ERROR                   NUMBER(1,0),
    RESULTSTATUS            VARCHAR2(20 BYTE),
    STOPPED                 VARCHAR2(20 BYTE),
    CONSTRAINT chartevents_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table CPTEVENTS
--------------------------------------------------------

DROP TABLE CPTEVENTS;
CREATE TABLE CPTEVENTS (
    ROW_ID           NUMBER(10,0) NOT NULL,
    SUBJECT_ID       NUMBER(7,0) NOT NULL,
    HADM_ID          NUMBER(7,0) NOT NULL,
    COSTCENTER       VARCHAR(4) NOT NULL,
    CHARTDATE        DATE,
    CPT_CD           VARCHAR2(5) NOT NULL,
    CPT_NUMBER       NUMBER(5,0),
    CPT_SUFFIX       VARCHAR2(1),
    TICKET_ID_SEQ    NUMBER(5,0),
    SECTIONHEADER    VARCHAR2(30),
    SUBSECTIONHEADER VARCHAR2(180),
    DESCRIPTION      VARCHAR2(100),
    CONSTRAINT cpt_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table DATETIMEEVENTS
--------------------------------------------------------

DROP TABLE DATETIMEEVENTS;
CREATE TABLE DATETIMEEVENTS (
    ROW_ID                  NUMBER(10,0) NOT NULL,
    SUBJECT_ID	            NUMBER(7,0) NOT NULL,
    HADM_ID	                NUMBER(7,0),
    ICUSTAY_ID	            NUMBER(7,0),
    ITEMID	                NUMBER(7,0) NOT NULL,
    CHARTTIME	            DATE NOT NULL,
    STORETIME	            DATE NOT NULL,
    CGID                    NUMBER(7,0) NOT NULL,
    VALUE	                DATE,
    VALUEUOM                VARCHAR2(20 BYTE) NOT NULL,
    WARNING	                NUMBER(1,0),
    ERROR	                NUMBER(1,0),
    RESULTSTATUS	        VARCHAR2(20 BYTE),
    STOPPED	                VARCHAR2(20 BYTE),
    CONSTRAINT datetime_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table DIAGNOSES_ICD
--------------------------------------------------------

DROP TABLE DIAGNOSES_ICD;
CREATE TABLE DIAGNOSES_ICD (
    ROW_ID	                NUMBER(10,0) NOT NULL,
    SUBJECT_ID	            NUMBER(7,0) NOT NULL,
    HADM_ID	                NUMBER(7,0) NOT NULL,
    SEQ_NUM	            NUMBER(5,0),
    ICD9_CODE	            VARCHAR2(7 BYTE),
    CONSTRAINT diagnosesicd_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table DRGCODES
--------------------------------------------------------

DROP TABLE DRGCODES;
CREATE TABLE DRGCODES (
    ROW_ID              NUMBER(10,0) NOT NULL,
    SUBJECT_ID          NUMBER(7,0) NOT NULL,
    HADM_ID             NUMBER(7,0) NOT NULL,
    DRG_TYPE	        VARCHAR2(4 BYTE) NOT NULL,
    DRG_CODE	        VARCHAR2(10 BYTE) NOT NULL,
    DESCRIPTION	        VARCHAR2(195 BYTE),
    DRG_SEVERITY	    NUMBER(1,0),
    DRG_MORTALITY	    NUMBER(1,0),
    CONSTRAINT drg_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table D_CPT
--------------------------------------------------------

DROP TABLE D_CPT;
CREATE TABLE D_CPT (
    ROW_ID                  NUMBER(10) NOT NULL,
    CATEGORY                NUMBER(1) NOT NULL,
    SECTIONRANGE            VARCHAR2(40 CHAR) NOT NULL,
    SECTIONHEADER           VARCHAR2(30) NOT NULL,
    SUBSECTIONRANGE         VARCHAR2(50) NOT NULL,
    SUBSECTIONHEADER        VARCHAR2(180) NOT NULL,
    CODESUFFIX              VARCHAR2(1),
    MINCODEINSUBSECTION     NUMBER(5) NOT NULL,
    MAXCODEINSUBSECTION     NUMBER(5) NOT NULL,
    CONSTRAINT dcpt_ssrange_unique UNIQUE (SUBSECTIONRANGE),
    CONSTRAINT dcpt_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table D_ICD_DIAGNOSES
--------------------------------------------------------

DROP TABLE D_ICD_DIAGNOSES;
CREATE TABLE D_ICD_DIAGNOSES (
    ROW_ID              NUMBER(5,0) NOT NULL,
    ICD9_CODE           VARCHAR2(6) NOT NULL,
    SHORT_TITLE         VARCHAR2(24) NOT NULL,
    LONG_TITLE          VARCHAR2(222) NOT NULL,
    CONSTRAINT d_icd_diag_code_unique UNIQUE (CODE_ICD9),
    CONSTRAINT d_icd_diag_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table D_ICD_PROCEDURES
--------------------------------------------------------

DROP TABLE D_ICD_PROCEDURES;
CREATE TABLE D_ICD_PROCEDURES (
    ROW_ID              NUMBER(5,0) NOT NULL,
    ICD9_CODE           VARCHAR2(6) NOT NULL,
    SHORT_TITLE         VARCHAR2(24) NOT NULL,
    LONG_TITLE          VARCHAR2(222) NOT NULL,
    CONSTRAINT d_icd_proc_code_unique UNIQUE (CODE_ICD9),
    CONSTRAINT d_icd_proc_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table D_ITEMS
--------------------------------------------------------

DROP TABLE D_ITEMS;
CREATE TABLE D_ITEMS (
    ROW_ID              NUMBER(10,0) NOT NULL,
    ITEMID              NUMBER(7,0) NOT NULL,
    LABEL               VARCHAR2(100),
    ABBREVIATION        VARCHAR2(50),
    DBSOURCE            VARCHAR2(12), -- database the data is sourced from
    LINKSTO             VARCHAR2(30),
    CATEGORY            VARCHAR2(50),
    UNITNAME            VARCHAR2(50), -- only for metavision data
    PARAM_TYPE          VARCHAR2(20), -- only for metavision data
    LOWNORMALVALUE      FLOAT, -- only for metavision data
    HIGHNORMALVALUE     FLOAT, -- only for metavision data
    CONCEPTID           NUMBER(7,0),
    CONSTRAINT ditems_itemid_unique UNIQUE (ITEMID),
    CONSTRAINT ditems_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table D_LABITEMS
--------------------------------------------------------

DROP TABLE D_LABITEMS;
CREATE TABLE D_LABITEMS (
    ROW_ID              NUMBER(10,0) NOT NULL,
    ITEMID              NUMBER(7,0) NOT NULL,
    LABEL               VARCHAR2(50) NOT NULL,
    FLUID               VARCHAR2(50) NOT NULL,
    CATEGORY            VARCHAR2(50) NOT NULL,
    LOINC_CODE          VARCHAR2(50),
    CONSTRAINT dlabitems_itemid_unique UNIQUE (ITEMID),
    CONSTRAINT dlabitems_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table ICUSTAYS
--------------------------------------------------------

DROP TABLE ICUSTAYS;
CREATE TABLE ICUSTAYS (
    ROW_ID          NUMBER(10,0) NOT NULL,
    SUBJECT_ID	    NUMBER(7,0) NOT NULL,
    HADM_ID	        NUMBER(7,0) NOT NULL,
    ICUSTAY_ID	    NUMBER(7,0) NOT NULL,
    DBSOURCE	    VARCHAR2(10 BYTE) NOT NULL,
    FIRST_CAREUNIT  VARCHAR2(15 BYTE) NOT NULL,
    LAST_CAREUNIT   VARCHAR2(15 BYTE) NOT NULL,
    FIRST_WARDID    NUMBER(5,0) NOT NULL,
    LAST_WARDID	    NUMBER(5,0) NOT NULL,
    INTIME	        DATE NOT NULL,
    OUTTIME	        DATE, -- nullable, ADT data sometimes missing disch for patients.
    LOS	            NUMBER,
    CONSTRAINT      icustay_icustayid_unique UNIQUE (ICUSTAY_ID),
    CONSTRAINT      icustay_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table IOEVENTS
--------------------------------------------------------

DROP TABLE IOEVENTS;
    create table ioevents (
    -- row identifier
    ROW_ID              NUMBER(10,0) NOT NULL,
    -- anonymous identifier
    SUBJECT_ID          NUMBER(7) NOT NULL,
    HADM_ID             NUMBER(7),
    ICUSTAY_ID          NUMBER(7),
    -- drug ITEMID and LABEL
    STARTTIME           DATE,
    ENDTIME             DATE,
    ITEMID              NUMBER(7),
    VOLUME              NUMBER,
    VOLUMEUOM           VARCHAR2(20),
    RATE                NUMBER,
    RATEUOM             VARCHAR2(20),
    STORETIME           DATE,
    CGID                NUMBER(10),
    -- metavision specific information orderids
    ORDERID             NUMBER(10),
    LINKORDERID         NUMBER(10),
    ORDERCATEGORYNAME   VARCHAR2(50),
    SECONDARYORDERCATEGORYNAME      VARCHAR2(50),
    ORDERCOMPONENTTYPEDESCRIPTION   VARCHAR2(100),
    ORDERCATEGORYDESCRIPTION        VARCHAR2(30),
    PATIENTWEIGHT       FLOAT(126),
    TOTALVOLUME         NUMBER,
    TOTALVOLUMEUOM      NVARCHAR2(50),
    -- METAVISION STATUS
    STATUSDESCRIPTION   VARCHAR2(20),
    -- mimic2v26 flags
    STOPPED             VARCHAR2(20),
    NEWBOTTLE           NUMBER,
    -- metavision flags
    ISOPENBAG           NUMBER(1),
    CONTINUEINNEXTDEPT  NUMBER(1),
    CANCELREASON        NUMBER(1),
    -- comments, exist in both DBs
    COMMENTS_STATUS     VARCHAR2(20),
    COMMENTS_TITLE      VARCHAR2(50),
    COMMENTS_DATE       DATE,
    -- original time of the solution/additive
    ORIGINALCHARTTIME   DATE,
    ORIGINALAMOUNT      NUMBER,
    ORIGINALAMOUNTUOM   VARCHAR2(20),
    ORIGINALROUTE       VARCHAR2(20),
    ORIGINALRATE        NUMBER,
    ORIGINALRATEUOM     VARCHAR2(20),
    ORIGINALSITE        VARCHAR2(20),
    CONSTRAINT ioevents_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table LABEVENTS
--------------------------------------------------------

DROP TABLE LABEVENTS;
CREATE TABLE LABEVENTS (
    ROW_ID              NUMBER(10,0) NOT NULL,
    SUBJECT_ID	        NUMBER(7,0) NOT NULL,
    HADM_ID	            NUMBER(7,0),
    ITEMID	            NUMBER(7,0) NOT NULL,
    CHARTTIME	        DATE NOT NULL,
    VALUE	            VARCHAR2(100 BYTE),
    VALUENUM	        NUMBER,
    VALUEUOM            VARCHAR2(10 BYTE),
    FLAG	            VARCHAR2(10 BYTE),
    CONSTRAINT labevents_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table MICROBIOLOGYEVENTS
--------------------------------------------------------

DROP TABLE MICROBIOLOGYEVENTS;
CREATE TABLE MICROBIOLOGYEVENTS (
    ROW_ID              NUMBER(10,0) NOT NULL,
    SUBJECT_ID          NUMBER(7,0) NOT NULL,
    HADM_ID             NUMBER(7,0),
    CHARTDATE           DATE,
    CHARTTIME           DATE,
    SPEC_ITEMID         NUMBER(7,0),
    SPEC_TYPE_CD        VARCHAR2(5),
    SPEC_TYPE_DESC      VARCHAR2(60),
    ORG_ITEMID          NUMBER(7,0),
    ORG_CD              NUMBER(4,0),
    ORG_NAME            VARCHAR2(70),
    ISOLATE_NUM         NUMBER(1,0),
    AB_ITEMID           NUMBER(7,0),
    AB_CD               NUMBER(2,0),
    AB_NAME             VARCHAR2(20),
    DILUTION_TEXT       VARCHAR2(6),
    DILUTION_COMPARISON VARCHAR2(10),
    DILUTION_VALUE      NUMBER(3,0),
    INTERPRETATION      VARCHAR2(1),
    CONSTRAINT micro_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table NOTEEVENTS
--------------------------------------------------------

DROP TABLE NOTEEVENTS;
CREATE TABLE NOTEEVENTS (
    ROW_ID	            NUMBER(10,0) NOT NULL,
    RECORD_ID	        NUMBER(7,0) NOT NULL,
    SUBJECT_ID	        NUMBER(7,0) NOT NULL,
    HADM_ID	            NUMBER(7,0),
    CHARTDATE           DATE,
    CATEGORY	        VARCHAR2(26 BYTE),
    DESCRIPTION	        VARCHAR2(255 BYTE),
    CGID	            NUMBER(7,0),
    ISERROR	            CHAR(1 BYTE),
    TEXT	            CLOB,
    CONSTRAINT noteevents_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table PATIENTS
--------------------------------------------------------

DROP TABLE PATIENTS;
CREATE TABLE PATIENTS (
    ROW_ID              NUMBER(10,0) NOT NULL,
    SUBJECT_ID          NUMBER(7,0) NOT NULL,
    GENDER              VARCHAR2(1) NOT NULL,
    DOB                 DATE NOT NULL,
    DOD                 DATE,
    DOD_HOSP            DATE,
    DOD_SSN             DATE,
    HOSPITAL_EXPIRE_FLAG VARCHAR2(1) NOT NULL,
    CONSTRAINT pat_subid_unique UNIQUE (SUBJECT_ID),
    CONSTRAINT pat_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table PRESCRIPTIONS
--------------------------------------------------------

DROP TABLE PRESCRIPTIONS;
CREATE TABLE PRESCRIPTIONS (
    ROW_ID	            NUMBER(10,0) NOT NULL,
    SUBJECT_ID	        NUMBER(7,0) NOT NULL,
    HADM_ID	            NUMBER(7,0) NOT NULL,
    ICUSTAY_ID	        NUMBER(7,0),
    STARTTIME	        DATE,
    ENDTIME	            DATE,
    DRUG_TYPE	        VARCHAR2(80 BYTE) NOT NULL,
    DRUG	            VARCHAR2(80 BYTE) NOT NULL,
    DRUG_NAME_POE	    VARCHAR2(80 BYTE),
    DRUG_NAME_GENERIC	VARCHAR2(50 BYTE),
    FORMULARY_DRUG_CD	VARCHAR2(90 BYTE),
    GSN	                VARCHAR2(180 BYTE),
    NDC	                VARCHAR2(90 BYTE),
    PROD_STRENGTH	    VARCHAR2(90 BYTE),
    DOSE_VAL_RX	        VARCHAR2(90 BYTE),
    DOSE_UNIT_RX	    VARCHAR2(90 BYTE),
    FORM_VAL_DISP	    VARCHAR2(90 BYTE),
    FORM_UNIT_DISP	    VARCHAR2(90 BYTE),
    ROUTE	            VARCHAR2(60 BYTE),
    CONSTRAINT prescription_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table PROCEDURES_ICD
--------------------------------------------------------

DROP TABLE PROCEDURES_ICD;
CREATE TABLE PROCEDURES_ICD (
    ROW_ID                      NUMBER(10,0) NOT NULL,
    SUBJECT_ID                  NUMBER(7,0) NOT NULL,
    HADM_ID                     NUMBER(7,0) NOT NULL,
    SEQ_NUM                NUMBER(3,0) NOT NULL,
    ICD9_CODE                   VARCHAR2(10) NOT NULL,
  CONSTRAINT proceduresicd_rowid_pk PRIMARY KEY (ROW_ID)
  );

--------------------------------------------------------
--  DDL for Table SERVICES
--------------------------------------------------------

DROP TABLE SERVICES;
CREATE TABLE SERVICES (
    ROW_ID NUMBER(10,0)         NOT NULL,
    SUBJECT_ID NUMBER(7,0)      NOT NULL,
    HADM_ID NUMBER(7,0)         NOT NULL,
    TRANSFERTIME                DATE NOT NULL,
    PREV_SERVICE                VARCHAR2(10),
    CURR_SERVICE                VARCHAR2(10),
    CONSTRAINT services_rowid_pk PRIMARY KEY (ROW_ID)
    );

--------------------------------------------------------
--  DDL for Table TRANSFERS
--------------------------------------------------------

DROP TABLE TRANSFERS;
CREATE TABLE TRANSFERS (
    ROW_ID	            NUMBER(10,0) NOT NULL,
    SUBJECT_ID	        NUMBER(7,0) NOT NULL,
    HADM_ID	            NUMBER(7,0) NOT NULL,
    ICUSTAY_ID	        NUMBER(7,0),
    DBSOURCE	        VARCHAR2(10 BYTE) NOT NULL,
    EVENTTYPE	        VARCHAR2(10 BYTE),
    PREV_CAREUNIT	    VARCHAR2(15 BYTE),
    CURR_CAREUNIT	    VARCHAR2(15 BYTE),
    PREV_WARDID	        NUMBER(5,0),
    CURR_WARDID	        NUMBER(5,0),
    INTIME	            DATE,
    OUTTIME	            DATE,
    LOS	                NUMBER,
  CONSTRAINT transfers_rowid_pk PRIMARY KEY (ROW_ID)
  );
