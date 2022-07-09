#!/bin/sh

# Copyright (c) 2021 Thomas Ward <thomas@thomasward.com>
# Copyright (c) 2019 MIT Laboratory for Computational Physiology
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

yell () { echo "$0: $*" >&2; }
die () { yell "$*"; exit 111; }
try () { "$@" || die "Exiting. Failed to run: \"$*\""; }

usage () {
    die "
USAGE: ./import_duckdb.sh mimic_data_dir [output_db]
WHERE:
    mimic_data_dir        directory that contains csv.tar.gz or csv files
    output_db: optional   filename for duckdb file (default: mimic4.db)\
"
}

# Print help if requested
echo "$0 $* " | grep -Eq " -h | --help " && usage

# rename CLI positional args to more friendly variable names
MIMIC_DIR=$1
# allow optional specification of duckdb name, otherwise default to mimic4.db
OUTFILE=mimic4.db
if [ -n "$2" ]; then
    OUTFILE=$2
fi


# basic error checking before running
if [ -z "$MIMIC_DIR" ]; then
    yell "Please specify a mimic data directory"
    die "Usage: ./import_duckdb.sh mimic_data_dir [output_db]"
elif [ ! -d "$MIMIC_DIR" ]; then
    yell "Specified directory \"$MIMIC_DIR\" does not exist."
    die "Usage: ./import_duckdb.sh mimic_data_dir [output_db]"
elif [ -n "$3" ]; then
    yell "import.sh takes a maximum of two arguments."
    die "Usage: ./import_duckdb.sh mimic_data_dir [output_db]"
elif [ -s "$OUTFILE" ]; then
    yell "File \"$OUTFILE\" already exists."
    die "Please specify an alternate output db name."
fi


# create database schemas and tables
# below SQL is "create.sql" from mimic-iv postgres git repo,
# with the following changes:
# 1. Remove optional precision value from TIMESTAMP(NN) -> TIMESTAMP
#    duckdb does not support this.
# 2. Remove NOT NULL constraint from mimic_hosp.microbiologyevents.spec_type_desc
#    as there is one (!) zero-length string which is treated as a NULL by the import.
# 3. Remove NOT NULL constraint from mimic_hosp.prescriptions.drug
#    as there are zero-length strings which are treated as NULLs by the import.
try duckdb "$OUTFILE" <<EOSQL
-------------------------------------------
-- Create the tables and MIMIC-IV schema --
-------------------------------------------

----------------------
-- Creating schemas --
----------------------

DROP SCHEMA IF EXISTS mimic_hosp CASCADE;
CREATE SCHEMA mimic_hosp;
DROP SCHEMA IF EXISTS mimic_icu CASCADE;
CREATE SCHEMA mimic_icu;

---------------------
-- Creating tables --
---------------------

DROP TABLE IF EXISTS mimic_hosp.admissions;
CREATE TABLE mimic_hosp.admissions
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  admittime TIMESTAMP NOT NULL,
  dischtime TIMESTAMP,
  deathtime TIMESTAMP,
  admission_type VARCHAR(40) NOT NULL,
  admission_location VARCHAR(60),
  discharge_location VARCHAR(60),
  insurance VARCHAR(255),
  language VARCHAR(10),
  marital_status VARCHAR(30),
  race VARCHAR(80),
  edregtime TIMESTAMP,
  edouttime TIMESTAMP,
  hospital_expire_flag SMALLINT
);

DROP TABLE IF EXISTS mimic_hosp.patients;
CREATE TABLE mimic_hosp.patients
(
  subject_id INTEGER NOT NULL,
  gender CHAR(1) NOT NULL,
  anchor_age SMALLINT,
  anchor_year SMALLINT NOT NULL,
  anchor_year_group VARCHAR(20) NOT NULL,
  dod DATE
);

DROP TABLE IF EXISTS mimic_hosp.transfers;
CREATE TABLE mimic_hosp.transfers
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER,
  transfer_id INTEGER NOT NULL,
  eventtype VARCHAR(10),
  careunit VARCHAR(255),
  intime TIMESTAMP,
  outtime TIMESTAMP
);

-- hosp schema

DROP TABLE IF EXISTS mimic_hosp.d_hcpcs;
CREATE TABLE mimic_hosp.d_hcpcs
(
  code CHAR(5) NOT NULL,
  category SMALLINT,
  long_description TEXT,
  short_description VARCHAR(180)
);

DROP TABLE IF EXISTS mimic_hosp.diagnoses_icd;
CREATE TABLE mimic_hosp.diagnoses_icd
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  seq_num INTEGER NOT NULL,
  icd_code CHAR(7),
  icd_version SMALLINT
);

DROP TABLE IF EXISTS mimic_hosp.d_icd_diagnoses;
CREATE TABLE mimic_hosp.d_icd_diagnoses
(
  icd_code CHAR(7) NOT NULL,
  icd_version SMALLINT NOT NULL,
  long_title VARCHAR(255)
);

DROP TABLE IF EXISTS mimic_hosp.d_icd_procedures;
CREATE TABLE mimic_hosp.d_icd_procedures
(
  icd_code CHAR(7) NOT NULL,
  icd_version SMALLINT NOT NULL,
  long_title VARCHAR(222)
);

DROP TABLE IF EXISTS mimic_hosp.d_labitems;
CREATE TABLE mimic_hosp.d_labitems
(
  itemid INTEGER NOT NULL,
  label VARCHAR(50),
  fluid VARCHAR(50),
  category VARCHAR(50)
);

DROP TABLE IF EXISTS mimic_hosp.drgcodes;
CREATE TABLE mimic_hosp.drgcodes
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  drg_type VARCHAR(4),
  drg_code VARCHAR(10) NOT NULL,
  description VARCHAR(195),
  drg_severity SMALLINT,
  drg_mortality SMALLINT
);

DROP TABLE IF EXISTS mimic_hosp.emar_detail;
CREATE TABLE mimic_hosp.emar_detail
(
  subject_id INTEGER NOT NULL,
  emar_id VARCHAR(25) NOT NULL,
  emar_seq INTEGER NOT NULL,
  parent_field_ordinal NUMERIC(3, 2),
  administration_type VARCHAR(50),
  pharmacy_id INTEGER,
  barcode_type VARCHAR(4),
  reason_for_no_barcode TEXT,
  complete_dose_not_given VARCHAR(5),
  dose_due VARCHAR(100),
  dose_due_unit VARCHAR(50),
  dose_given VARCHAR(255),
  dose_given_unit VARCHAR(50),
  will_remainder_of_dose_be_given VARCHAR(5),
  product_amount_given VARCHAR(30),
  product_unit VARCHAR(30),
  product_code VARCHAR(30),
  product_description VARCHAR(255),
  product_description_other VARCHAR(255),
  prior_infusion_rate VARCHAR(20),
  infusion_rate VARCHAR(20),
  infusion_rate_adjustment VARCHAR(50),
  infusion_rate_adjustment_amount VARCHAR(30),
  infusion_rate_unit VARCHAR(30),
  route VARCHAR(10),
  infusion_complete VARCHAR(1),
  completion_interval VARCHAR(30),
  new_iv_bag_hung VARCHAR(1),
  continued_infusion_in_other_location VARCHAR(1),
  restart_interval VARCHAR(2305),
  side VARCHAR(10),
  site VARCHAR(255),
  non_formulary_visual_verification VARCHAR(1)
);

DROP TABLE IF EXISTS mimic_hosp.emar;
CREATE TABLE mimic_hosp.emar
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER,
  emar_id VARCHAR(25) NOT NULL,
  emar_seq INTEGER NOT NULL,
  poe_id VARCHAR(25) NOT NULL,
  pharmacy_id INTEGER,
  charttime TIMESTAMP NOT NULL,
  medication TEXT,
  event_txt VARCHAR(100),
  scheduletime TIMESTAMP,
  storetime TIMESTAMP NOT NULL
);

DROP TABLE IF EXISTS mimic_hosp.hcpcsevents;
CREATE TABLE mimic_hosp.hcpcsevents
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  chartdate TIMESTAMP NOT NULL,
  hcpcs_cd CHAR(5) NOT NULL,
  seq_num INTEGER NOT NULL,
  short_description VARCHAR(180)
);

DROP TABLE IF EXISTS mimic_hosp.labevents;
CREATE TABLE mimic_hosp.labevents
(
  labevent_id INTEGER NOT NULL,
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER,
  specimen_id INTEGER NOT NULL,
  itemid INTEGER NOT NULL,
  charttime TIMESTAMP,
  storetime TIMESTAMP,
  value VARCHAR(200),
  valuenum DOUBLE PRECISION,
  valueuom VARCHAR(20),
  ref_range_lower DOUBLE PRECISION,
  ref_range_upper DOUBLE PRECISION,
  flag VARCHAR(10),
  priority VARCHAR(7),
  comments TEXT
);

DROP TABLE IF EXISTS mimic_hosp.microbiologyevents;
CREATE TABLE mimic_hosp.microbiologyevents
(
  microevent_id INTEGER NOT NULL,
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER,
  micro_specimen_id INTEGER NOT NULL,
  chartdate TIMESTAMP NOT NULL,
  charttime TIMESTAMP,
  spec_itemid INTEGER NOT NULL,
  spec_type_desc VARCHAR(100),
  test_seq INTEGER NOT NULL,
  storedate TIMESTAMP,
  storetime TIMESTAMP,
  test_itemid INTEGER,
  test_name VARCHAR(100),
  org_itemid INTEGER,
  org_name VARCHAR(100),
  isolate_num SMALLINT,
  quantity VARCHAR(50),
  ab_itemid INTEGER,
  ab_name VARCHAR(30),
  dilution_text VARCHAR(10),
  dilution_comparison VARCHAR(20),
  dilution_value DOUBLE PRECISION,
  interpretation VARCHAR(5),
  comments TEXT
);

DROP TABLE IF EXISTS mimic_hosp.omr;
CREATE TABLE mimic_hosp.omr
(
  subject_id INTEGER NOT NULL,
  chartdate TIMESTAMP NOT NULL,
  seq_num INTEGER NOT NULL,
  result_name VARCHAR(255) NOT NULL,
  result_value VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS mimic_hosp.pharmacy;
CREATE TABLE mimic_hosp.pharmacy
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  pharmacy_id INTEGER NOT NULL,
  poe_id VARCHAR(25),
  starttime TIMESTAMP,
  stoptime TIMESTAMP,
  medication TEXT,
  proc_type VARCHAR(50) NOT NULL,
  status VARCHAR(50),
  entertime TIMESTAMP NOT NULL,
  verifiedtime TIMESTAMP,
  route VARCHAR(50),
  frequency VARCHAR(50),
  disp_sched VARCHAR(255),
  infusion_type VARCHAR(15),
  sliding_scale VARCHAR(1),
  lockout_interval VARCHAR(50),
  basal_rate REAL,
  one_hr_max VARCHAR(10),
  doses_per_24_hrs REAL,
  duration REAL,
  duration_interval VARCHAR(50),
  expiration_value INTEGER,
  expiration_unit VARCHAR(50),
  expirationdate TIMESTAMP,
  dispensation VARCHAR(50),
  fill_quantity VARCHAR(50)
);

DROP TABLE IF EXISTS mimic_hosp.poe_detail;
CREATE TABLE mimic_hosp.poe_detail
(
  poe_id VARCHAR(25) NOT NULL,
  poe_seq INTEGER NOT NULL,
  subject_id INTEGER NOT NULL,
  field_name VARCHAR(255) NOT NULL,
  field_value TEXT
);

DROP TABLE IF EXISTS mimic_hosp.poe;
CREATE TABLE mimic_hosp.poe
(
  poe_id VARCHAR(25) NOT NULL,
  poe_seq INTEGER NOT NULL,
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER,
  ordertime TIMESTAMP NOT NULL,
  order_type VARCHAR(25) NOT NULL,
  order_subtype VARCHAR(50),
  transaction_type VARCHAR(15),
  discontinue_of_poe_id VARCHAR(25),
  discontinued_by_poe_id VARCHAR(25),
  order_status VARCHAR(15)
);

DROP TABLE IF EXISTS mimic_hosp.prescriptions;
CREATE TABLE mimic_hosp.prescriptions
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  pharmacy_id INTEGER NOT NULL,
  poe_id VARCHAR(25),
  poe_seq INTEGER,
  starttime TIMESTAMP,
  stoptime TIMESTAMP,
  drug_type VARCHAR(20) NOT NULL,
  drug VARCHAR(255),
  formulary_drug_cd VARCHAR(50),
  gsn VARCHAR(255),
  ndc VARCHAR(25),
  prod_strength VARCHAR(255),
  form_rx VARCHAR(25),
  dose_val_rx VARCHAR(100),
  dose_unit_rx VARCHAR(50),
  form_val_disp VARCHAR(50),
  form_unit_disp VARCHAR(50),
  doses_per_24_hrs REAL,
  route VARCHAR(50)
);

DROP TABLE IF EXISTS mimic_hosp.procedures_icd;
CREATE TABLE mimic_hosp.procedures_icd
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  seq_num INTEGER NOT NULL,
  chartdate TIMESTAMP NOT NULL,
  icd_code VARCHAR(7),
  icd_version SMALLINT
);

DROP TABLE IF EXISTS mimic_hosp.services;
CREATE TABLE mimic_hosp.services
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  transfertime TIMESTAMP NOT NULL,
  prev_service VARCHAR(10),
  curr_service VARCHAR(10)
);

-- icu schema

DROP TABLE IF EXISTS mimic_icu.chartevents;
CREATE TABLE mimic_icu.chartevents
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  stay_id INTEGER NOT NULL,
  charttime TIMESTAMP NOT NULL,
  storetime TIMESTAMP,
  itemid INTEGER NOT NULL,
  value VARCHAR(200),
  valuenum FLOAT,
  valueuom VARCHAR(20),
  warning SMALLINT
);

DROP TABLE IF EXISTS mimic_icu.datetimeevents;
CREATE TABLE mimic_icu.datetimeevents
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  stay_id INTEGER NOT NULL,
  charttime TIMESTAMP NOT NULL,
  storetime TIMESTAMP,
  itemid INTEGER NOT NULL,
  value TIMESTAMP NOT NULL,
  valueuom VARCHAR(20),
  warning SMALLINT
);

DROP TABLE IF EXISTS mimic_icu.d_items;
CREATE TABLE mimic_icu.d_items
(
  itemid INTEGER NOT NULL,
  label VARCHAR(100) NOT NULL,
  abbreviation VARCHAR(50) NOT NULL,
  linksto VARCHAR(30) NOT NULL,
  category VARCHAR(50) NOT NULL,
  unitname VARCHAR(50),
  param_type VARCHAR(20) NOT NULL,
  lownormalvalue FLOAT,
  highnormalvalue FLOAT
);

DROP TABLE IF EXISTS mimic_icu.icustays;
CREATE TABLE mimic_icu.icustays
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  stay_id INTEGER NOT NULL,
  first_careunit VARCHAR(255),
  last_careunit VARCHAR(255),
  intime TIMESTAMP,
  outtime TIMESTAMP,
  los FLOAT
);

DROP TABLE IF EXISTS mimic_icu.ingredientevents;
CREATE TABLE mimic_icu.ingredientevents(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  stay_id INTEGER,
  starttime TIMESTAMP NOT NULL,
  endtime TIMESTAMP NOT NULL,
  storetime TIMESTAMP,
  itemid INTEGER NOT NULL,
  amount FLOAT,
  amountuom VARCHAR(20),
  rate FLOAT,
  rateuom VARCHAR(20),
  orderid INTEGER NOT NULL,
  linkorderid INTEGER,
  statusdescription VARCHAR(20),
  originalamount FLOAT,
  originalrate FLOAT
);

DROP TABLE IF EXISTS mimic_icu.inputevents;
CREATE TABLE mimic_icu.inputevents
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  stay_id INTEGER,
  starttime TIMESTAMP NOT NULL,
  endtime TIMESTAMP NOT NULL,
  storetime TIMESTAMP,
  itemid INTEGER NOT NULL,
  amount FLOAT,
  amountuom VARCHAR(20),
  rate FLOAT,
  rateuom VARCHAR(20),
  orderid INTEGER NOT NULL,
  linkorderid INTEGER,
  ordercategoryname VARCHAR(50),
  secondaryordercategoryname VARCHAR(50),
  ordercomponenttypedescription VARCHAR(100),
  ordercategorydescription VARCHAR(30),
  patientweight FLOAT,
  totalamount FLOAT,
  totalamountuom VARCHAR(50),
  isopenbag SMALLINT,
  continueinnextdept SMALLINT,
  statusdescription VARCHAR(20),
  originalamount FLOAT,
  originalrate FLOAT
);

DROP TABLE IF EXISTS mimic_icu.outputevents;
CREATE TABLE mimic_icu.outputevents
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  stay_id INTEGER NOT NULL,
  charttime TIMESTAMP NOT NULL,
  storetime TIMESTAMP NOT NULL,
  itemid INTEGER NOT NULL,
  value FLOAT NOT NULL,
  valueuom VARCHAR(20)
);

DROP TABLE IF EXISTS mimic_icu.procedureevents;
CREATE TABLE mimic_icu.procedureevents
(
  subject_id INTEGER NOT NULL,
  hadm_id INTEGER NOT NULL,
  stay_id INTEGER NOT NULL,
  starttime TIMESTAMP NOT NULL,
  endtime TIMESTAMP NOT NULL,
  storetime TIMESTAMP NOT NULL,
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
  statusdescription VARCHAR(20),
  originalamount FLOAT,
  originalrate FLOAT
);
EOSQL

# goal: get path from find, e.g., ./1.0/icu/d_items
# and return database table name for it, e.g., mimic_icu.d_items
make_table_name () {
    # strip leading directories (e.g., ./icu/hello.csv.gz -> hello.csv.gz)
    BASENAME=${1##*/}
    # strip suffix (e.g., hello.csv.gz -> hello; hello.csv -> hello)
    TABLE_NAME=${BASENAME%%.*}
    # strip basename (e.g., ./icu/hello.csv.gz -> ./icu)
    PATHNAME=${1%/*}
    # strip leading directories from PATHNAME (e.g. ./icu -> icu)
    DIRNAME=${PATHNAME##*/}
    TABLE_NAME="mimic_$DIRNAME.$TABLE_NAME"
}


# load data into database
find "$MIMIC_DIR" -type f -name '*.csv???' | sort | while IFS= read -r FILE; do
    make_table_name "$FILE"
    echo "Loading $FILE."
    try duckdb "$OUTFILE" <<-EOSQL
		COPY $TABLE_NAME FROM '$FILE' (HEADER);
EOSQL
    echo "Finished loading $FILE."
done && echo "Successfully finished loading data into $OUTFILE."
