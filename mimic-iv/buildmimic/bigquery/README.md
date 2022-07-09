# Loading MIMIC-IV to BigQuery

**YOU DO NOT NEED TO INSTALL MIMIC-IV YOURSELF!** MIMIC-IV has been loaded onto BigQuery by the LCP, and is available for credentialed researchers to access. If you are credentialed, then you may be granted access MIMIC-IV on BigQuery instantly by following the [cloud configuration tutorial](https://mimic.mit.edu/docs/gettingstarted/cloud/).

The following instructions are provided for transparency and were used to create the current copy of MIMIC-IV on BigQuery.

---

## STEP 1: Acquire access to the source files

> NOTE: According to the BigQuery documentation (Last updated May 4, 2018.), "BigQuery can load uncompressed files significantly faster than compressed files because uncompressed files can be read in parallel. Because uncompressed files are larger, using them can lead to bandwidth limitations and higher Google Cloud Storage costs for data staged in Google Cloud Storage prior to being loaded into BigQuery". The site also states that "currently, there is no charge for loading data into BigQuery".

MIMIC-IV is only available to approved users. You may request access via the [MIMIC-IV project page on PhysioNet](https://physionet.org/content/mimiciv/). Once approved, there are a number of access options:

![Description of Google access options for MIMIC-IV](mimic_request_access.png)

**Important**: If you are only interested in *using* the data on BigQuery, then you can simply request access to the dataset and query it directly. You do *not* need to follow this guide. The rest of this guide is intended for users who wish to re-build MIMIC-IV on their own BigQuery project.

## STEP 2: Install Google Cloud SDK

### A) Install `google-cloud-sdk`.

```sh
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt-get update && sudo apt-get install google-cloud-sdk
```

### B) Start Google Cloud. The system should open an Internet browser and ask you to login to Google Cloud Platform and select a default project.

```sh
gcloud init
```

---

## STEP 3: Download the MIMIC-IV files

Download the MIMIC-IV dataset files. The easiest way to download them is to open a terminal then run:

```
wget -r -N -c -np --user YOURUSERNAME --ask-password https://physionet.org/files/mimiciv/2.0/
```

Replace `YOURUSERNAME` with your physionet username.

Then, upload the folders (`hosp` and `icu`) to a GCP bucket of your choice:

```sh
bucket="mimic-data"

gsutil -m cp -r hosp icu gs://$bucket/v2.0/
```

## STEP 4: Create a new BigQuery dataset

### A) Create a new dataset for MIMIC-IV version 2.0

In this example, we have chosen **mimic4_v2_0** as the dataset prefix for the ICU/hosp modules.

```sh
bq mk --dataset --data_location US --description "MIMIC-IV version 2.0 ICU data" mimic4_v2_0_icu
bq mk --dataset --data_location US --description "MIMIC-IV version 2.0 hosp data" mimic4_v2_0_hosp
```

### B) Check the status of the dataset created

```sh
bq show mimic4_v2_0_hosp
```

---

## STEP 5: Download the table schemas

> NOTE: BigQuery has an option to automatically detect a table schema, but we found some issues with data type compatibility for seven tables (see below). For example, some columns received a different data type than listed on the MIMIC webpage (ex: string instead of integer). According to BigQuery documentation, "When auto-detection is enabled, BigQuery starts the inference process by selecting a random file in the data source and scanning up to 100 rows of data to use as a representative sample. BigQuery then examines each field and attempts to assign a data type to that field based on the values in the sample". (source: https://cloud.google.com/bigquery/docs/schema-detect).

> NOTE: "When you supply a JSON schema file, it must be stored in a locally readable location. You cannot specify a JSON schema file stored in Cloud Storage or Google Drive". (source: https://cloud.google.com/bigquery/docs/schemas)

BigQuery schemas are defined by JSON files. These files are an array of dictionaries with four fields: the name of the column (`name`), the data type of the column (`type`), an optional field restricting nulls (`mode`, default is NULLABLE), and an optional field providing a description of the column (`description`).

```json
{
    "mode": "NULLABLE",
    "name": "ROW_ID",
    "type": "INTEGER"
}
```

BigQuery schemas are provided in this GitHub repository. Download the table schemas from the subfolder **schemas** to a local folder.

---

## STEP 6: Create tables and load the compressed files

### A) Create a script file (ex: upload_mimic4_v2_0.sh) and copy the code below.

You will need to change the **schema_local_folder** to match the path to the schemas on your local machine.

Note also that the below assumes the following dataset structure:

* <dataset_prefix>_icu
* <dataset_prefix>_hosp

If you would like all tables on the same dataset, you should modify the below script accordingly.

```sh
#!/bin/bash

# Initialize parameters
bucket="mimic-data"  # we chose this bucket earlier when uploading data
dataset_prefix="mimic4_v2_0"
schema_local_folder="~/mimic-code/mimic-iv/buildmimic/bigquery/schemas"

# Get the list of files in the bucket

for module in hosp icu;
do
    FILES=$(gsutil ls gs://$bucket/v2.0/$module/*.csv.gz)

    for file in $FILES
    do

    # Extract the table name from the file path (ex: gs://mimic4_v2_0/ADMISSIONS.csv.gz)
    base=${file##*/}            # remove path
    filename=${base%.*}         # remove .gz
    tablename=${filename%.*}    # remove .csv

    # Create table and populate it with data from the bucket
    bq load --allow_quoted_newlines --skip_leading_rows=1 --source_format=CSV --replace ${dataset_prefix}_${module}.$tablename gs://$bucket/v2.0/$module/$tablename.csv.gz $schema_local_folder/$module/$tablename.json

    # Check for error
    if [ $? -eq 0 ];then
        echo "OK....$tablename"
    else
        echo "FAIL..$tablename"
    fi

    done
done
exit 0
```

This code will get the list of files in the bucket, and for each file, it will extract the table name (ex: *admissions*). With the table name, the system executes the BigQuery load command `bq load` to create a table and load the data from the csv.gz file from the bucket using the specific schema from the local folder. The script will need (1) the name of the bucket where the compressed files are stored on Cloud Storage, (2) the name of the dataset to create and upload the tables, and (3) the path to the JSON file (schema) on your local machine.

### B) Set the CHMOD to allow the file as executable (ex: 755), and execute the script file

```sh
./upload_mimic4_v2_0.sh
```

### C) Results of the upload process

The system will print **OK** or **FAIL** for each file processed. In case of failure, the system also prints a message with information about the error.

#### Upload OK

```sh
Waiting on bqjob_r62d6560c318d991a_00000177f4a22a95_1 ... (4s) Current status: DONE  
OK....ADMISSIONS
```

#### Upload FAIL

```sh
Waiting on bqjob_r3c23bb4d717cd8a9_000001620e9d5f6d_1 ... (496s) Current status: DONE
BigQuery error in load operation: Error processing job
'sandbox-nlp:bqjob_r3c23bb4d717cd8a9_000001620e9d5f6d_1': Error while reading data, error message: CSV table encountered too many errors, giving up. Rows: 63349; errors: 1. Please look into the error stream for more details.
Failure details:
- gs://mimiciv-1.0.physionet.org/chartevents.csv.gz: Error while reading data,
error message: Could not parse 'No' as double for field VALUE
(position 8) starting at location 3353598526
FAIL..chartevents
```

#### Full output anticipated

The full output should look something like this:

```
Waiting on bqjob_r62d6560c318d991a_00000177f4a22a95_1 ... (7s) Current status: DONE   
OK....admissions
Waiting on bqjob_r47de57d5853a02df_00000177f4a2528f_1 ... (2s) Current status: DONE   
OK....patients
Waiting on bqjob_r39d4d7ad7e1e1393_00000177f4a2646e_1 ... (23s) Current status: DONE   
OK....transfers
Waiting on bqjob_r6d55a1c40466490f_00000177f4a2cbd6_1 ... (1s) Current status: DONE   
OK....d_hcpcs
Waiting on bqjob_r7be7886ff4309aef_00000177f4a2d97f_1 ... (1s) Current status: DONE   
OK....d_icd_diagnoses
Waiting on bqjob_r3b1bab017c630628_00000177f4a2e703_1 ... (1s) Current status: DONE   
OK....d_icd_procedures
Waiting on bqjob_r4f20adae22208858_00000177f4a2f479_1 ... (0s) Current status: DONE   
OK....d_labitems
Waiting on bqjob_r29620a6f3012bfe4_00000177f4a2fd71_1 ... (23s) Current status: DONE   
OK....diagnoses_icd
Waiting on bqjob_r6d6a02810aa45c88_00000177f4a361a6_1 ... (5s) Current status: DONE   
OK....drgcodes
Waiting on bqjob_re0dd27ed1853ec1_00000177f4a380d2_1 ... (254s) Current status: DONE   
OK....emar
Waiting on bqjob_r39e61fc8bb996428_00000177f4a76d4c_1 ... (375s) Current status: DONE   
OK....emar_detail
Waiting on bqjob_r2c30f44d3da8d0cd_00000177f4ad31d9_1 ... (2s) Current status: DONE   
OK....hcpcsevents
Waiting on bqjob_r3686b5b4b6a22def_00000177f4ad44dc_1 ... (797s) Current status: DONE   
OK....labevents
Waiting on bqjob_r6a896e170257f60e_00000177f4b97a15_1 ... (65s) Current status: DONE   
OK....microbiologyevents
Waiting on bqjob_r1a722205e1dad7a9_00000177f4ba8456_1 ... (108s) Current status: DONE   
OK....note
Waiting on bqjob_r1c4ba80cb44c271d_00000177f4bc3685_1 ... (0s) Current status: DONE   
OK....note_detail
Waiting on bqjob_rf7b708a80accdd7_00000177f4bc402f_1 ... (224s) Current status: DONE   
OK....pharmacy
Waiting on bqjob_r624a5dcfb4d949ab_00000177f4bfb5f9_1 ... (254s) Current status: DONE   
OK....poe
Waiting on bqjob_r5462a353a52559a4_00000177f4c3a2a1_1 ... (23s) Current status: DONE   
OK....poe_detail
Waiting on bqjob_r5859ef22aa540208_00000177f4c406b5_1 ... (194s) Current status: DONE   
OK....prescriptions
Waiting on bqjob_r20e7000c9498d2cb_00000177f4c70684_1 ... (4s) Current status: DONE   
OK....procedures_icd
Waiting on bqjob_r679b8ebf0b305fdf_00000177f4c720d8_1 ... (6s) Current status: DONE   
OK....services
Waiting on bqjob_r4335eebbc0d294ef_00000177f4c7490d_1 ... (1491s) Current status: DONE   
OK....chartevents
Waiting on bqjob_rf493fd1cf9fdda6_00000177f4de15c4_1 ... (0s) Current status: DONE   
OK....d_items
Waiting on bqjob_r6dae247c09f4a6f1_00000177f4de1ee7_1 ... (65s) Current status: DONE   
OK....datetimeevents
Waiting on bqjob_r35317c1866c5eefe_00000177f4df2851_1 ... (2s) Current status: DONE   
OK....icustays
Waiting on bqjob_r460b37bad7971d3f_00000177f4df3a24_1 ... (164s) Current status: DONE   
OK....inputevents
Waiting on bqjob_r69c5cf34b671d133_00000177f4e1c4d0_1 ... (34s) Current status: DONE   
OK....outputevents
Waiting on bqjob_r38c99e75592b2a1e_00000177f4e253bc_1 ... (15s) Current status: DONE   
OK....procedureevents
```


## STEP 7: Validate your dataset works

We can test a successful build by running a check query.

```sh
bq query --use_legacy_sql=False 'select CASE WHEN count(*) = 383220 THEN True ELSE
False end AS check from `mimic4_v2_0.patients`'
```

This verifies we have the expected row count in the patients table. It's further possible to check the row counts of the other tables by comparing to the already existing MIMIC-IV BigQuery dataset available on `physionet-data`.