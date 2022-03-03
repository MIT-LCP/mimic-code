CREATE DATABASE IF NOT EXISTS `mimiciv_csv`;
CREATE EXTERNAL TABLE `mimiciv_csv`.`admissions`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `admittime` string, 
  `dischtime` string, 
  `deathtime` string, 
  `admission_type` string, 
  `admission_location` string, 
  `discharge_location` string, 
  `insurance` string, 
  `language` string, 
  `marital_status` string, 
  `ethnicity` string, 
  `edregtime` string, 
  `edouttime` string, 
  `hospital_expire_flag` bigint)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/core/admissions/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`patients`(
  `subject_id` bigint, 
  `gender` string, 
  `anchor_age` bigint, 
  `anchor_year` bigint, 
  `anchor_year_group` string, 
  `dod` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/core/patients/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`transfers`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `transfer_id` bigint, 
  `eventtype` string, 
  `careunit` string, 
  `intime` string, 
  `outtime` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/core/transfers/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');




CREATE EXTERNAL TABLE `mimiciv_csv`.`chartevents`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `stay_id` bigint, 
  `charttime` string, 
  `storetime` string, 
  `itemid` bigint, 
  `value` double, 
  `valuenum` double, 
  `valueuom` string, 
  `warning` bigint)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/icu/chartevents/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`datetimeevents`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `stay_id` bigint, 
  `charttime` string, 
  `storetime` string, 
  `itemid` bigint, 
  `value` string, 
  `valueuom` string, 
  `warning` bigint)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/icu/datetimeevents/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`d_items`(
  `itemid` bigint, 
  `label` string, 
  `abbreviation` string, 
  `linksto` string, 
  `category` string, 
  `unitname` string, 
  `param_type` string, 
  `lownormalvalue` bigint, 
  `highnormalvalue` double)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/icu/d_items/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`icustays`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `stay_id` bigint, 
  `first_careunit` string, 
  `last_careunit` string, 
  `intime` string, 
  `outtime` string, 
  `los` double)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/icu/icustays/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`inputevents`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `stay_id` bigint, 
  `starttime` string, 
  `endtime` string, 
  `storetime` string, 
  `itemid` bigint, 
  `amount` double, 
  `amountuom` string, 
  `rate` double, 
  `rateuom` string, 
  `orderid` bigint, 
  `linkorderid` bigint, 
  `ordercategoryname` string, 
  `secondaryordercategoryname` string, 
  `ordercomponenttypedescription` string, 
  `ordercategorydescription` string, 
  `patientweight` double, 
  `totalamount` bigint, 
  `totalamountuom` string, 
  `isopenbag` bigint, 
  `continueinnextdept` bigint, 
  `cancelreason` bigint, 
  `statusdescription` string, 
  `originalamount` double, 
  `originalrate` double)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/icu/inputevents/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`outputevents`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `stay_id` bigint, 
  `charttime` string, 
  `storetime` string, 
  `itemid` bigint, 
  `value` double, 
  `valueuom` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/icu/outputevents/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`procedureevents`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `stay_id` bigint, 
  `starttime` string, 
  `endtime` string, 
  `storetime` string, 
  `itemid` bigint, 
  `value` double, 
  `valueuom` string, 
  `location` string, 
  `locationcategory` string, 
  `orderid` bigint, 
  `linkorderid` bigint, 
  `ordercategoryname` string, 
  `secondaryordercategoryname` string, 
  `ordercategorydescription` string, 
  `patientweight` double, 
  `totalamount` string, 
  `totalamountuom` string, 
  `isopenbag` bigint, 
  `continueinnextdept` bigint, 
  `cancelreason` bigint, 
  `statusdescription` string, 
  `comments_date` string, 
  `originalamount` double, 
  `originalrate` bigint)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/icu/procedureevents/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');




CREATE EXTERNAL TABLE `mimiciv_csv`.`d_hcpcs`(
  `code` string, 
  `category` bigint, 
  `long_description` string, 
  `short_description` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/d_hcpcs/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`d_icd_diagnoses`(
  `icd_code` bigint, 
  `icd_version` bigint, 
  `long_title` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/d_icd_diagnoses/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`d_icd_procedures`(
  `icd_code` string, 
  `icd_version` bigint, 
  `long_title` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/d_icd_procedures/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`d_labitems`(
  `itemid` bigint, 
  `label` string, 
  `fluid` string, 
  `category` string, 
  `loinc_code` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/d_labitems/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`diagnoses_icd`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `seq_num` bigint, 
  `icd_code` string, 
  `icd_version` bigint)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/diagnoses_icd/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`drgcodes`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `drg_type` string, 
  `drg_code` bigint, 
  `description` string, 
  `drg_severity` string, 
  `drg_mortality` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/drgcodes/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`emar`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `emar_id` string, 
  `emar_seq` bigint, 
  `poe_id` string, 
  `pharmacy_id` bigint, 
  `charttime` string, 
  `medication` string, 
  `event_txt` string, 
  `scheduletime` string, 
  `storetime` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/emar/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`emar_detail`(
  `subject_id` bigint, 
  `emar_id` string, 
  `emar_seq` bigint, 
  `parent_field_ordinal` double, 
  `administration_type` string, 
  `pharmacy_id` bigint, 
  `barcode_type` string, 
  `reason_for_no_barcode` string, 
  `complete_dose_not_given` string, 
  `dose_due` string, 
  `dose_due_unit` string, 
  `dose_given` double, 
  `dose_given_unit` string, 
  `will_remainder_of_dose_be_given` string, 
  `product_amount_given` double, 
  `product_unit` string, 
  `product_code` string, 
  `product_description` string, 
  `product_description_other` string, 
  `prior_infusion_rate` bigint, 
  `infusion_rate` bigint, 
  `infusion_rate_adjustment` string, 
  `infusion_rate_adjustment_amount` string, 
  `infusion_rate_unit` string, 
  `route` string, 
  `infusion_complete` string, 
  `completion_interval` string, 
  `new_iv_bag_hung` string, 
  `continued_infusion_in_other_location` string, 
  `restart_interval` string, 
  `side` string, 
  `site` string, 
  `non_formulary_visual_verification` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/emar_detail/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`hcpcsevents`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `chartdate` string, 
  `hcpcs_cd` string, 
  `seq_num` bigint, 
  `short_description` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/hcpcsevents/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`labevents`(
  `labevent_id` bigint, 
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `specimen_id` bigint, 
  `itemid` bigint, 
  `charttime` string, 
  `storetime` string, 
  `value` double, 
  `valuenum` double, 
  `valueuom` string, 
  `ref_range_lower` double, 
  `ref_range_upper` double, 
  `flag` string, 
  `priority` string, 
  `comments` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/labevents/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`microbiologyevents`(
  `microevent_id` bigint, 
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `micro_specimen_id` bigint, 
  `chartdate` string, 
  `charttime` string, 
  `spec_itemid` bigint, 
  `spec_type_desc` string, 
  `test_seq` bigint, 
  `storedate` string, 
  `storetime` string, 
  `test_itemid` bigint, 
  `test_name` string, 
  `org_itemid` bigint, 
  `org_name` string, 
  `isolate_num` bigint, 
  `quantity` string, 
  `ab_itemid` bigint, 
  `ab_name` string, 
  `dilution_text` string, 
  `dilution_comparison` string, 
  `dilution_value` double, 
  `interpretation` string, 
  `comments` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/microbiologyevents/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`pharmacy`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `pharmacy_id` bigint, 
  `poe_id` string, 
  `starttime` string, 
  `stoptime` string, 
  `medication` string, 
  `proc_type` string, 
  `status` string, 
  `entertime` string, 
  `verifiedtime` string, 
  `route` string, 
  `frequency` string, 
  `disp_sched` string, 
  `infusion_type` string, 
  `sliding_scale` string, 
  `lockout_interval` bigint, 
  `basal_rate` bigint, 
  `one_hr_max` string, 
  `doses_per_24_hrs` bigint, 
  `duration` bigint, 
  `duration_interval` string, 
  `expiration_value` bigint, 
  `expiration_unit` string, 
  `expirationdate` string, 
  `dispensation` string, 
  `fill_quantity` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/pharmacy/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`poe`(
  `poe_id` string, 
  `poe_seq` bigint, 
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `ordertime` string, 
  `order_type` string, 
  `order_subtype` string, 
  `transaction_type` string, 
  `discontinue_of_poe_id` string, 
  `discontinued_by_poe_id` string, 
  `order_status` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/poe/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`poe_detail`(
  `poe_id` string, 
  `poe_seq` bigint, 
  `subject_id` bigint, 
  `field_name` string, 
  `field_value` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/poe_detail/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`prescriptions`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `pharmacy_id` bigint, 
  `starttime` string, 
  `stoptime` string, 
  `drug_type` string, 
  `drug` string, 
  `gsn` bigint, 
  `ndc` bigint, 
  `prod_strength` string, 
  `form_rx` string, 
  `dose_val_rx` string, 
  `dose_unit_rx` string, 
  `form_val_disp` string, 
  `form_unit_disp` string, 
  `doses_per_24_hrs` bigint, 
  `route` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/prescriptions/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`procedures_icd`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `seq_num` bigint, 
  `chartdate` string, 
  `icd_code` bigint, 
  `icd_version` bigint)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/procedures_icd/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
CREATE EXTERNAL TABLE `mimiciv_csv`.`services`(
  `subject_id` bigint, 
  `hadm_id` bigint, 
  `transfertime` string, 
  `prev_service` string, 
  `curr_service` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://MIMICIV_BUCKET/csv/hosp/services/'
TBLPROPERTIES (
  'ColumnsQuoted'='false', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',',  
  'skip.header.line.count'='1', 
  'typeOfData'='file');
