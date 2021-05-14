## This job takes in the MIMIC-III CSV.gz files from the specified input bucket
## and converts them to Parquet format in the specified output bucket
## Author:  James Wiggins (wiggjame@amazon.com)
## Date:  6/3/19
## Revision: 1

import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.functions import *
from pyspark.sql.types import *
import os.path
from os import path
import boto3

s3 = boto3.resource('s3')
glueContext = GlueContext(SparkContext.getOrCreate())
spark = glueContext.spark_session

# Specify MIMIC data input and output S3 buckets
mimiccsvinputbucket='mimic-iii-physionet'
mimicparquetoutputbucket='mimic-iii-physionet'
mimicparquetoutputprefix='parquet/'


# ADMISSIONS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("admittime", TimestampType()),
    StructField("dischtime", TimestampType()),
    StructField("deathtime", TimestampType()),
    StructField("admission_type", StringType()),
    StructField("admission_location", StringType()),
    StructField("discharge_location", StringType()),
    StructField("insurance", StringType()),
    StructField("language", StringType()),
    StructField("religion", StringType()),
    StructField("marital_status", StringType()),
    StructField("ethnicity", StringType()),
    StructField("edregtime", TimestampType()),
    StructField("edouttime", TimestampType()),
    StructField("diagnosis", StringType()),
    StructField("hospital_expire_flag", ShortType()),
    StructField("has_chartevents_data", ShortType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/ADMISSIONS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')
    
df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'ADMISSIONS', compression="snappy", mode="Overwrite")


# CALLOUT table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("submit_wardid", IntegerType()),
    StructField("submit_careunit", StringType()),
    StructField("curr_wardid", IntegerType()),
    StructField("curr_careunit", StringType()),
    StructField("callout_wardid", IntegerType()),
    StructField("callout_service", StringType()),
    StructField("request_tele", ShortType()),
    StructField("request_resp", ShortType()),
    StructField("request_cdiff", ShortType()),
    StructField("request_mrsa", ShortType()),
    StructField("request_vre", ShortType()),
    StructField("callout_status", StringType()),
    StructField("callout_outcome", StringType()),
    StructField("discharge_wardid", IntegerType()),
    StructField("acknowledge_status", StringType()),
    StructField("createtime", TimestampType()),
    StructField("updatetime", TimestampType()),
    StructField("acknowledgetime", TimestampType()),
    StructField("outcometime", TimestampType()),
    StructField("firstreservationtime", TimestampType()),
    StructField("currentreservationtime", TimestampType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/CALLOUT.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'CALLOUT', compression="snappy", mode="Overwrite")


# CAREGIVERS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("cgid", IntegerType()),
    StructField("label", StringType()),
    StructField("description", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/CAREGIVERS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'CAREGIVERS', compression="snappy", mode="Overwrite")


# CHARTEVENTS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("icustay_id", IntegerType()),
    StructField("itemid", IntegerType()),
    StructField("charttime", TimestampType()),
    StructField("storetime", TimestampType()),
    StructField("cgid", IntegerType()),
    StructField("value", StringType()),
    StructField("valuenum", DoubleType()),
    StructField("valueuom", StringType()),
    StructField("warning", IntegerType()),
    StructField("error", IntegerType()),
    StructField("resultstatus", StringType()),
    StructField("stopped", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/CHARTEVENTS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'CHARTEVENTS', compression="snappy", mode="Overwrite")


# CPTEVENTS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("costcenter", StringType()),
    StructField("chartdate", TimestampType()),
    StructField("cpt_cd", StringType()),
    StructField("cpt_number", IntegerType()),
    StructField("cpt_suffix", StringType()),
    StructField("ticket_id_seq", IntegerType()),
    StructField("sectionheader", StringType()),
    StructField("subsectionheader", StringType()),
    StructField("description", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/CPTEVENTS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'CPTEVENTS', compression="snappy", mode="Overwrite")


# D_CPT table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("category", ShortType()),
    StructField("sectionrange", StringType()),
    StructField("sectionheader", StringType()),
    StructField("subsectionrange", StringType()),
    StructField("subsectionheader", StringType()),
    StructField("codesuffix", StringType()),
    StructField("mincodeinsubsection", IntegerType()),
    StructField("maxcodeinsubsection", IntegerType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/D_CPT.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'D_CPT', compression="snappy", mode="Overwrite")


# D_ICD_DIAGNOSES table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("icd9_code", StringType()),
    StructField("short_title", StringType()),
    StructField("long_title", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/D_ICD_DIAGNOSES.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'D_ICD_DIAGNOSES', compression="snappy", mode="Overwrite")


# D_ICD_PROCEDURES table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("icd9_code", StringType()),
    StructField("short_title", StringType()),
    StructField("long_title", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/D_ICD_PROCEDURES.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'D_ICD_PROCEDURES', compression="snappy", mode="Overwrite")


# D_ITEMS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("itemid", IntegerType()),
    StructField("label", StringType()),
    StructField("abbreviation", StringType()),
    StructField("dbsource", StringType()),
    StructField("linksto", StringType()),
    StructField("category", StringType()),
    StructField("unitname", StringType()),
    StructField("param_type", StringType()),
    StructField("conceptid", IntegerType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/D_ITEMS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')
df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'D_ITEMS', compression="snappy", mode="Overwrite")


# D_LABITEMS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("itemid", IntegerType()),
    StructField("label", StringType()),
    StructField("fluid", StringType()),
    StructField("category", StringType()),
    StructField("loinc_code", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/D_LABITEMS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'D_LABITEMS', compression="snappy", mode="Overwrite")


# DATETIMEEVENTS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("icustay_id", IntegerType()),
    StructField("itemid", IntegerType()),
    StructField("charttime", TimestampType()),
    StructField("storetime", TimestampType()),
    StructField("cgid", IntegerType()),
    StructField("value", StringType()),
    StructField("valueuom", StringType()),
    StructField("warning", IntegerType()),
    StructField("error", IntegerType()),
    StructField("resultstatus", StringType()),
    StructField("stopped", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/DATETIMEEVENTS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'DATETIMEEVENTS', compression="snappy", mode="Overwrite")


# DIAGNOSES_ICD table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("seq_num", IntegerType()),
    StructField("icd9_code", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/DIAGNOSES_ICD.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'DIAGNOSES_ICD', compression="snappy", mode="Overwrite")


# DRGCODES table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("drg_type", StringType()),
    StructField("drg_code", StringType()),
    StructField("description", StringType()),
    StructField("drg_severity", ShortType()),
    StructField("drg_mortality", ShortType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/DRGCODES.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'DRGCODES', compression="snappy", mode="Overwrite")


# ICUSTAYS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("icustay_id", IntegerType()),
    StructField("dbsource", StringType()),
    StructField("first_careunit", StringType()),
    StructField("last_careunit", StringType()),
    StructField("first_wardid", ShortType()),
    StructField("last_wardid", ShortType()),
    StructField("intime", TimestampType()),
    StructField("outtime", TimestampType()),
    StructField("los", DoubleType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/ICUSTAYS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'ICUSTAYS', compression="snappy", mode="Overwrite")


# INPUTEVENTS_CV table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("icustay_id", IntegerType()),
    StructField("charttime", TimestampType()),
    StructField("itemid", IntegerType()),
    StructField("amount", DoubleType()),
    StructField("amountuom", StringType()),
    StructField("rate", DoubleType()),
    StructField("rateuom", StringType()),
    StructField("storetime", TimestampType()),
    StructField("cgid", IntegerType()),
    StructField("orderid", IntegerType()),
    StructField("linkorderid", IntegerType()),
    StructField("stopped", StringType()),
    StructField("newbottle", IntegerType()),
    StructField("originalamount", DoubleType()),
    StructField("originalamountuom", StringType()),
    StructField("originalroute", StringType()),
    StructField("originalrate", DoubleType()),
    StructField("originalrateuom", StringType()),
    StructField("originalsite", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/INPUTEVENTS_CV.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'INPUTEVENTS_CV', compression="snappy", mode="Overwrite")


# INPUTEVENTS_MV table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("icustay_id", IntegerType()),
    StructField("starttime", TimestampType()),
    StructField("endtime", TimestampType()),
    StructField("itemid", IntegerType()),
    StructField("amount", DoubleType()),
    StructField("amountuom", StringType()),
    StructField("rate", DoubleType()),
    StructField("rateuom", StringType()),
    StructField("storetime", TimestampType()),
    StructField("cgid", IntegerType()),
    StructField("orderid", IntegerType()),
    StructField("linkorderid", IntegerType()),
    StructField("ordercategoryname", StringType()),
    StructField("secondaryordercategoryname", StringType()),
    StructField("ordercomponenttypedescription", StringType()),
    StructField("ordercategorydescription", StringType()),
    StructField("patientweight", DoubleType()),
    StructField("totalamount", DoubleType()),
    StructField("totalamountuom", StringType()),
    StructField("isopenbag", ShortType()),
    StructField("continueinnextdept", ShortType()),
    StructField("cancelreason", ShortType()),
    StructField("statusdescription", StringType()),
    StructField("comments_editedby", StringType()),
    StructField("comments_canceledby", StringType()),
    StructField("comments_date", TimestampType()),
    StructField("originalamount", DoubleType()),
    StructField("originalrate", DoubleType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/INPUTEVENTS_MV.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'INPUTEVENTS_MV', compression="snappy", mode="Overwrite")


# LABEVENTS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("itemid", IntegerType()),
    StructField("charttime", TimestampType()),
    StructField("value", StringType()),
    StructField("valuenum", DoubleType()),
    StructField("valueuom", StringType()),
    StructField("flag", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/LABEVENTS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'LABEVENTS', compression="snappy", mode="Overwrite")


# MICROBIOLOGYEVENTS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("chartdate", TimestampType()),
    StructField("charttime", TimestampType()),
    StructField("spec_itemid", IntegerType()),
    StructField("spec_type_desc", StringType()),
    StructField("org_itemid", IntegerType()),
    StructField("org_name", StringType()),
    StructField("isolate_num", ShortType()),
    StructField("ab_itemid", IntegerType()),
    StructField("ab_name", StringType()),
    StructField("dilution_text", StringType()),
    StructField("dilution_comparison", StringType()),
    StructField("dilution_value", DoubleType()),
    StructField("interpretation", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/MICROBIOLOGYEVENTS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'MICROBIOLOGYEVENTS', compression="snappy", mode="Overwrite")


# NOTEEVENTS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("chartdate", TimestampType()),
    StructField("charttime", TimestampType()),
    StructField("storetime", TimestampType()),
    StructField("category", StringType()),
    StructField("description", StringType()),
    StructField("cgid", IntegerType()),
    StructField("iserror", StringType()),
    StructField("text", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/NOTEEVENTS.csv.gz',\
header=True,\
schema=schema,\
multiLine=True,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'NOTEEVENTS', compression="snappy", mode="Overwrite")


# OUTPUTEVENTS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("icustay_id", IntegerType()),
    StructField("charttime", TimestampType()),
    StructField("itemid", IntegerType()),
    StructField("value", DoubleType()),
    StructField("valueuom", StringType()),
    StructField("storetime", TimestampType()),
    StructField("cgid", IntegerType()),
    StructField("stopped", StringType()),
    StructField("newbottle", StringType()),
    StructField("iserror", IntegerType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/OUTPUTEVENTS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'OUTPUTEVENTS', compression="snappy", mode="Overwrite")


# PATIENTS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("gender", StringType()),
    StructField("dob", TimestampType()),
    StructField("dod", TimestampType()),
    StructField("dod_hosp", TimestampType()),
    StructField("dod_ssn", TimestampType()),
    StructField("expire_flag", IntegerType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/PATIENTS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'PATIENTS', compression="snappy", mode="Overwrite")


# PRESCRIPTIONS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("icustay_id", IntegerType()),
    StructField("startdate", TimestampType()),
    StructField("enddate", TimestampType()),
    StructField("drug_type", StringType()),
    StructField("drug", StringType()),
    StructField("drug_name_poe", StringType()),
    StructField("drug_name_generic", StringType()),
    StructField("formulary_drug_cd", StringType()),
    StructField("gsn", StringType()),
    StructField("ndc", StringType()),
    StructField("prod_strength", StringType()),
    StructField("dose_val_rx", StringType()),
    StructField("dose_unit_rx", StringType()),
    StructField("form_val_disp", StringType()),
    StructField("form_unit_disp", StringType()),
    StructField("route", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/PRESCRIPTIONS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'PRESCRIPTIONS', compression="snappy", mode="Overwrite")


# PROCEDUREEVENTS_MV table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("icustay_id", IntegerType()),
    StructField("starttime", TimestampType()),
    StructField("endtime", TimestampType()),
    StructField("itemid", IntegerType()),
    StructField("value", DoubleType()),
    StructField("valueuom", StringType()),
    StructField("location", StringType()),
    StructField("locationcategory", StringType()),
    StructField("storetime", TimestampType()),
    StructField("cgid", IntegerType()),
    StructField("orderid", IntegerType()),
    StructField("linkorderid", IntegerType()),
    StructField("ordercategoryname", StringType()),
    StructField("secondaryordercategoryname", StringType()),
    StructField("ordercategorydescription", StringType()),
    StructField("isopenbag", ShortType()),
    StructField("continueinnextdept", ShortType()),
    StructField("cancelreason", ShortType()),
    StructField("statusdescription", StringType()),
    StructField("comments_editedby", StringType()),
    StructField("comments_canceledby", StringType()),
    StructField("comments_date", TimestampType()),
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/PROCEDUREEVENTS_MV.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'PROCEDUREEVENTS_MV', compression="snappy", mode="Overwrite")


# PROCEDURES_ICD table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("seq_num", IntegerType()),
    StructField("icd9_code", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/PROCEDURES_ICD.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'PROCEDURES_ICD', compression="snappy", mode="Overwrite")


# SERVICES table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("transfertime", TimestampType()),
    StructField("prev_service", StringType()),
    StructField("curr_service", StringType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/SERVICES.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'SERVICES', compression="snappy", mode="Overwrite")


# TRANSFERS table parquet transformation
schema = StructType([
    StructField("row_id", IntegerType()),
    StructField("subject_id", IntegerType()),
    StructField("hadm_id", IntegerType()),
    StructField("icustay_id", IntegerType()),
    StructField("dbsource", StringType()),
    StructField("eventtype", StringType()),
    StructField("prev_careunit", StringType()),
    StructField("curr_careunit", StringType()),
    StructField("prev_wardid", ShortType()),
    StructField("curr_wardid", ShortType()),
    StructField("intime", TimestampType()),
    StructField("outtime", TimestampType()),
    StructField("los", DoubleType())
])

df = spark.read.csv('s3://'+mimiccsvinputbucket+'/TRANSFERS.csv.gz',\
header=True,\
schema=schema,\
quote='"',\
escape='"')

df.write.parquet('s3://'+mimicparquetoutputbucket+'/'+mimicparquetoutputprefix+'TRANSFERS', compression="snappy", mode="Overwrite")


