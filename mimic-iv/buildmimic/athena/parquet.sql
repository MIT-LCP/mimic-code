CREATE DATABASE IF NOT EXISTS `mimiciv_parquet`;

CREATE TABLE "mimiciv_parquet".admissions WITH (external_location = 's3://MIMICIV_BUCKET/parquet/admissions/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".admissions;
CREATE TABLE "mimiciv_parquet".patients   WITH (external_location = 's3://MIMICIV_BUCKET/parquet/patients/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".patients;
CREATE TABLE "mimiciv_parquet".transfers  WITH (external_location = 's3://MIMICIV_BUCKET/parquet/transfers/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".transfers;

CREATE TABLE "mimiciv_parquet".chartevents     WITH (external_location = 's3://MIMICIV_BUCKET/parquet/chartevents/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".chartevents;
CREATE TABLE "mimiciv_parquet".d_items         WITH (external_location = 's3://MIMICIV_BUCKET/parquet/d_items/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".d_items;
CREATE TABLE "mimiciv_parquet".datetimeevents  WITH (external_location = 's3://MIMICIV_BUCKET/parquet/datetimeevents/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".datetimeevents;
CREATE TABLE "mimiciv_parquet".icustays        WITH (external_location = 's3://MIMICIV_BUCKET/parquet/icustays/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".icustays;
CREATE TABLE "mimiciv_parquet".inputevents     WITH (external_location = 's3://MIMICIV_BUCKET/parquet/inputevents/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".inputevents;
CREATE TABLE "mimiciv_parquet".outputevents    WITH (external_location = 's3://MIMICIV_BUCKET/parquet/outputevents/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".outputevents;
CREATE TABLE "mimiciv_parquet".procedureevents WITH (external_location = 's3://MIMICIV_BUCKET/parquet/procedureevents/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".procedureevents;

CREATE TABLE "mimiciv_parquet".d_hcpcs            WITH (external_location = 's3://MIMICIV_BUCKET/parquet/d_hcpcs/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".d_hcpcs;
CREATE TABLE "mimiciv_parquet".d_icd_diagnoses    WITH (external_location = 's3://MIMICIV_BUCKET/parquet/d_icd_diagnoses/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".d_icd_diagnoses;
CREATE TABLE "mimiciv_parquet".d_icd_procedures   WITH (external_location = 's3://MIMICIV_BUCKET/parquet/d_icd_procedures/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".d_icd_procedures;
CREATE TABLE "mimiciv_parquet".d_labitems         WITH (external_location = 's3://MIMICIV_BUCKET/parquet/d_labitems/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".d_labitems;
CREATE TABLE "mimiciv_parquet".diagnoses_icd      WITH (external_location = 's3://MIMICIV_BUCKET/parquet/diagnoses_icd/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".diagnoses_icd;
CREATE TABLE "mimiciv_parquet".drgcodes           WITH (external_location = 's3://MIMICIV_BUCKET/parquet/drgcodes/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".drgcodes;
CREATE TABLE "mimiciv_parquet".emar               WITH (external_location = 's3://MIMICIV_BUCKET/parquet/emar/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".emar;
CREATE TABLE "mimiciv_parquet".emar_detail        WITH (external_location = 's3://MIMICIV_BUCKET/parquet/emar_detail/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".emar_detail;
CREATE TABLE "mimiciv_parquet".hcpcsevents        WITH (external_location = 's3://MIMICIV_BUCKET/parquet/hcpcsevents/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".hcpcsevents;
CREATE TABLE "mimiciv_parquet".labevents          WITH (external_location = 's3://MIMICIV_BUCKET/parquet/labevents/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".labevents;
CREATE TABLE "mimiciv_parquet".microbiologyevents WITH (external_location = 's3://MIMICIV_BUCKET/parquet/microbiologyevents/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".microbiologyevents;
CREATE TABLE "mimiciv_parquet".pharmacy           WITH (external_location = 's3://MIMICIV_BUCKET/parquet/pharmacy/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".pharmacy;
CREATE TABLE "mimiciv_parquet".poe                WITH (external_location = 's3://MIMICIV_BUCKET/parquet/poe/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".poe;
CREATE TABLE "mimiciv_parquet".poe_detail         WITH (external_location = 's3://MIMICIV_BUCKET/parquet/poe_detail/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".poe_detail;
CREATE TABLE "mimiciv_parquet".prescriptions      WITH (external_location = 's3://MIMICIV_BUCKET/parquet/prescriptions/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".prescriptions;
CREATE TABLE "mimiciv_parquet".procedures_icd     WITH (external_location = 's3://MIMICIV_BUCKET/parquet/procedures_icd/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".procedures_icd;
CREATE TABLE "mimiciv_parquet".services           WITH (external_location = 's3://MIMICIV_BUCKET/parquet/services/',format = 'Parquet') AS SELECT * FROM "mimiciv_csv".services;
