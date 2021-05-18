CREATE EXTERNAL TABLE `admissions`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `admittime` timestamp, 
  `dischtime` timestamp, 
  `deathtime` timestamp, 
  `admission_type` string, 
  `admission_location` string, 
  `discharge_location` string, 
  `insurance` string, 
  `language` string, 
  `religion` string, 
  `marital_status` string, 
  `ethnicity` string, 
  `edregtime` timestamp, 
  `edouttime` timestamp, 
  `diagnosis` string, 
  `hospital_expire_flag` smallint, 
  `has_chartevents_data` smallint)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/admissions/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='239', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='7903', 
  'sizeKey'='2525254', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `callout`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `submit_wardid` int, 
  `submit_careunit` string, 
  `curr_wardid` int, 
  `curr_careunit` string, 
  `callout_wardid` int, 
  `callout_service` string, 
  `request_tele` smallint, 
  `request_resp` smallint, 
  `request_cdiff` smallint, 
  `request_mrsa` smallint, 
  `request_vre` smallint, 
  `callout_status` string, 
  `callout_outcome` string, 
  `discharge_wardid` int, 
  `acknowledge_status` string, 
  `createtime` timestamp, 
  `updatetime` timestamp, 
  `acknowledgetime` timestamp, 
  `outcometime` timestamp, 
  `firstreservationtime` timestamp, 
  `currentreservationtime` timestamp)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/callout/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='249', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='3341', 
  'sizeKey'='1205036', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

  CREATE EXTERNAL TABLE `caregivers`(
  `row_id` int, 
  `cgid` int, 
  `label` string, 
  `description` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/caregivers/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='30', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='2118', 
  'sizeKey'='49529', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

  CREATE EXTERNAL TABLE `chartevents`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `icustay_id` int, 
  `itemid` int, 
  `charttime` timestamp, 
  `storetime` timestamp, 
  `cgid` int, 
  `value` string, 
  `valuenum` double, 
  `valueuom` string, 
  `warning` int, 
  `error` int, 
  `resultstatus` string, 
  `stopped` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/chartevents/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='114', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='48181790', 
  'sizeKey'='4287004212', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `cptevents`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `costcenter` string, 
  `chartdate` timestamp, 
  `cpt_cd` string, 
  `cpt_number` int, 
  `cpt_suffix` string, 
  `ticket_id_seq` int, 
  `sectionheader` string, 
  `subsectionheader` string, 
  `description` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/cptevents/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='118', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='88989', 
  'sizeKey'='4971247', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `d_cpt`(
  `row_id` int, 
  `category` smallint, 
  `sectionrange` string, 
  `sectionheader` string, 
  `subsectionrange` string, 
  `subsectionheader` string, 
  `codesuffix` string, 
  `mincodeinsubsection` int, 
  `maxcodeinsubsection` int)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/d-cpt/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='118', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='44', 
  'sizeKey'='3951', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `d_icd_diagnoses`(
  `row_id` int, 
  `icd9_code` string, 
  `short_title` string, 
  `long_title` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/d-icd-diagnoses/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='112', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='3662', 
  'sizeKey'='284950', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

  CREATE EXTERNAL TABLE `d_icd_procedures`(
  `row_id` int, 
  `icd9_code` string, 
  `short_title` string, 
  `long_title` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/d-icd-procedures/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='43', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='2099', 
  'sizeKey'='75848', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `d_items`(
  `row_id` int, 
  `itemid` int, 
  `label` string, 
  `abbreviation` string, 
  `dbsource` string, 
  `linksto` string, 
  `category` string, 
  `unitname` string, 
  `param_type` string, 
  `conceptid` int)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/d-items/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='82', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='2853', 
  'sizeKey'='187922', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `d_labitems`(
  `row_id` int, 
  `itemid` int, 
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
  's3://mimic-iii-physionet/parquet/d-labitems/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='66', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='266', 
  'sizeKey'='11492', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

  CREATE EXTERNAL TABLE `datetimeevents`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `icustay_id` int, 
  `itemid` int, 
  `charttime` timestamp, 
  `storetime` timestamp, 
  `cgid` int, 
  `value` timestamp, 
  `valueuom` string, 
  `warning` smallint, 
  `error` smallint, 
  `resultstatus` string, 
  `stopped` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/datetimeevents/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='112', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='822117', 
  'sizeKey'='55042057', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

  CREATE EXTERNAL TABLE `diagnoses_icd`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `seq_num` int, 
  `icd9_code` string)
ROW FORMAT DELIMITED
   FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/diagnoses-icd/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'averageRecordSize'='33', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='190697', 
  'sizeKey'='4717463', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

  CREATE EXTERNAL TABLE `drgcodes`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `drg_type` string, 
  `drg_code` string, 
  `description` string, 
  `drg_severity` smallint, 
  `drg_mortality` smallint)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/drgcodes/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='102', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='15163', 
  'sizeKey'='1750041', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `icustays`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `icustay_id` int, 
  `dbsource` string, 
  `first_careunit` string, 
  `last_careunit` string, 
  `first_wardid` smallint, 
  `last_wardid` smallint, 
  `intime` timestamp, 
  `outtime` timestamp, 
  `los` double)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/icustays/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='112', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='13639', 
  'sizeKey'='1990193', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `inputevents_cv`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `icustay_id` int, 
  `charttime` timestamp, 
  `itemid` int, 
  `amount` double, 
  `amountuom` string, 
  `rate` double, 
  `rateuom` string, 
  `storetime` timestamp, 
  `cgid` int, 
  `orderid` int, 
  `linkorderid` int, 
  `stopped` string, 
  `newbottle` int, 
  `originalamount` double, 
  `originalamountuom` string, 
  `originalroute` string, 
  `originalrate` double, 
  `originalrateuom` string, 
  `originalsite` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/inputevents-cv/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='169', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='3139155', 
  'sizeKey'='422105376', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `inputevents_mv`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `icustay_id` int, 
  `starttime` timestamp, 
  `endtime` timestamp, 
  `itemid` int, 
  `amount` double, 
  `amountuom` string, 
  `rate` double, 
  `rateuom` string, 
  `storetime` timestamp, 
  `cgid` int, 
  `orderid` int, 
  `linkorderid` int, 
  `ordercategoryname` string, 
  `secondaryordercategoryname` string, 
  `ordercomponenttypedescription` string, 
  `ordercategorydescription` string, 
  `patientweight` double, 
  `totalamount` double, 
  `totalamountuom` string, 
  `isopenbag` smallint, 
  `continueinnextdept` smallint, 
  `cancelreason` smallint, 
  `statusdescription` string, 
  `comments_editedby` string, 
  `comments_canceledby` string, 
  `comments_date` timestamp, 
  `originalamount` double, 
  `originalrate` double)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/inputevents-mv/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='381', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='324529', 
  'sizeKey'='150909733', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `labevents`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `itemid` int, 
  `charttime` timestamp, 
  `value` string, 
  `valuenum` double, 
  `valueuom` string, 
  `flag` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/labevents/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='61', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='6919679', 
  'sizeKey'='335843735', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `microbiologyevents`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `chartdate` timestamp, 
  `charttime` timestamp, 
  `spec_itemid` int, 
  `spec_type_desc` string, 
  `org_itemid` int, 
  `org_name` string, 
  `isolate_num` smallint, 
  `ab_itemid` int, 
  `ab_name` string, 
  `dilution_text` string, 
  `dilution_comparison` string, 
  `dilution_value` double, 
  `interpretation` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/microbiologyevents/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='139', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='79795', 
  'sizeKey'='7612452', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `noteevents`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `chartdate` timestamp, 
  `charttime` timestamp, 
  `storetime` timestamp, 
  `category` string, 
  `description` string, 
  `cgid` int, 
  `iserror` char, 
  `text` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/noteevents/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='true', 
  'averageRecordSize'='4483', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'commentCharacter'='#', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='158956', 
  'sizeKey'='1165661452', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `outputevents`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `icustay_id` int, 
  `charttime` timestamp, 
  `itemid` int, 
  `value` double, 
  `valueuom` string, 
  `storetime` timestamp, 
  `cgid` int, 
  `stopped` string, 
  `newbottle` char(1), 
  `iserror` int)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/outputevents/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='true', 
  'averageRecordSize'='103', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='1115852', 
  'sizeKey'='58436520', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `patients`(
  `row_id` int, 
  `subject_id` int, 
  `gender` string, 
  `dob` timestamp, 
  `dod` timestamp, 
  `dod_hosp` timestamp, 
  `dod_ssn` timestamp, 
  `expire_flag` int)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/patients/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='62', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='11236', 
  'sizeKey'='571615', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `prescriptions`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `icustay_id` int, 
  `startdate` timestamp, 
  `enddate` timestamp, 
  `drug_type` string, 
  `drug` string, 
  `drug_name_poe` string, 
  `drug_name_generic` string, 
  `formulary_drug_cd` string, 
  `gsn` string, 
  `ndc` string, 
  `prod_strength` string, 
  `dose_val_rx` string, 
  `dose_unit_rx` string, 
  `form_val_disp` string, 
  `form_unit_disp` string, 
  `route` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/prescriptions/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='192', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='627454', 
  'sizeKey'='103492087', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `procedureevents_mv`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `icustay_id` int, 
  `starttime` timestamp, 
  `endtime` timestamp, 
  `itemid` int, 
  `value` double, 
  `valueuom` string, 
  `location` string, 
  `locationcategory` string, 
  `storetime` timestamp, 
  `cgid` int, 
  `orderid` int, 
  `linkorderid` int, 
  `ordercategoryname` string, 
  `secondaryordercategoryname` string, 
  `ordercategorydescription` string, 
  `isopenbag` smallint, 
  `continueinnextdept` smallint, 
  `cancelreason` smallint, 
  `statusdescription` string, 
  `comments_editedby` string, 
  `comments_canceledby` string, 
  `comments_date` timestamp)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/procedureevents-mv/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='242', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='27055', 
  'sizeKey'='7814321', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `procedures_icd`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `seq_num` int, 
  `icd9_code` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/procedures-icd/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='34', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='66456', 
  'sizeKey'='1795004', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `services`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `transfertime` timestamp, 
  `prev_service` string, 
  `curr_service` string)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/services/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='57', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='15255', 
  'sizeKey'='1156392', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');

CREATE EXTERNAL TABLE `transfers`(
  `row_id` int, 
  `subject_id` int, 
  `hadm_id` int, 
  `icustay_id` int, 
  `dbsource` string, 
  `eventtype` string, 
  `prev_careunit` string, 
  `curr_careunit` string, 
  `prev_wardid` smallint, 
  `curr_wardid` smallint, 
  `intime` timestamp, 
  `outtime` timestamp, 
  `los` double)
ROW FORMAT DELIMITED 
  FIELDS TERMINATED BY ',' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://mimic-iii-physionet/parquet/transfers/'
TBLPROPERTIES (
  'CrawlerSchemaDeserializerVersion'='1.0', 
  'CrawlerSchemaSerializerVersion'='1.0', 
  'UPDATED_BY_CRAWLER'='mimiciiitest', 
  'areColumnsQuoted'='false', 
  'averageRecordSize'='118', 
  'classification'='csv', 
  'columnsOrdered'='true', 
  'compressionType'='gzip', 
  'delimiter'=',', 
  'objectCount'='1', 
  'recordCount'='45850', 
  'sizeKey'='5479949', 
  'skip.header.line.count'='1', 
  'typeOfData'='file');