# Installing MIMIC-III v1.4 to BigQuery

Following are the steps to create the MIMIC-III dataset on BigQuery and load the source files (.csv.gz) downloaded from Physionet.

**IMPORTANT**: Only users with approved Physionet Data Use Agreement (DUA) should have access to the MIMIC dataset via BigQuery or Cloud Storage. If you don't have access to MIMIC, follow the instructions [here](https://mimic.physionet.org/gettingstarted/access/) to request access.

---

## STEP 1: Acquire access to the MIMIC-III source files

> NOTE: According to the BigQuery documentation (Last updated May 4, 2018.), "BigQuery can load uncompressed files significantly faster than compressed files because uncompressed files can be read in parallel. Because uncompressed files are larger, using them can lead to bandwidth limitations and higher Google Cloud Storage costs for data staged in Google Cloud Storage prior to being loaded into BigQuery". The site also states that "currently, there is no charge for loading data into BigQuery".

For this tutorial, we will proceed using the compressed files (.csv.gz) stored in a Google Cloud Storage (GCS) bucket.
In order to use these files, you must have a Google account with access permission granted via PhysioNet.
You can read about being provisioned access to MIMIC-III on Google [on the cloud tutorial page](https://mimic.physionet.org/gettingstarted/cloud/).

Once you have configured your account on PhysioNet, go to the [MIMIC-III page on PhysioNet](https://physionet.org/content/mimiciii/) and scroll down to the Files section.

![Description of Google access options for MIMIC-III](mimiciii_request_access.png)

**Important**: If you are only interested in *using* the data on BigQuery, then you can simply request access to the dataset and query it directly. You do *not* need to follow this guide. The rest of this guide is intended for users who wish to re-build MIMIC-III on their own BigQuery project.

If you are interested in building MIMIC-III, acquire Google Cloud Storage access by clicking the link highlighted in the image above on the MIMIC-III page.

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

## STEP 3: Verify you can access the MIMIC-III files on Google Cloud Storage

### A) Check the content of the bucket.

```sh
gsutil ls gs://mimiciii-1.4.physionet.org
```

It should list all 26 MIMIC files (.csv.gz), and some auxiliary files associated with the project (README.md, SHA256SUMS.txt, checksum_md5_unzipped.txt, checksum_md5_zi).

```sh
gs://mimiciii-1.4.physionet.org/ADMISSIONS.csv.gz
gs://mimiciii-1.4.physionet.org/CALLOUT.csv.gz
gs://mimiciii-1.4.physionet.org/CAREGIVERS.csv.gz
gs://mimiciii-1.4.physionet.org/CHARTEVENTS.csv.gz
gs://mimiciii-1.4.physionet.org/CPTEVENTS.csv.gz
gs://mimiciii-1.4.physionet.org/DATETIMEEVENTS.csv.gz
gs://mimiciii-1.4.physionet.org/DIAGNOSES_ICD.csv.gz
gs://mimiciii-1.4.physionet.org/DRGCODES.csv.gz
gs://mimiciii-1.4.physionet.org/D_CPT.csv.gz
gs://mimiciii-1.4.physionet.org/D_ICD_DIAGNOSES.csv.gz
gs://mimiciii-1.4.physionet.org/D_ICD_PROCEDURES.csv.gz
gs://mimiciii-1.4.physionet.org/D_ITEMS.csv.gz
gs://mimiciii-1.4.physionet.org/D_LABITEMS.csv.gz
gs://mimiciii-1.4.physionet.org/ICUSTAYS.csv.gz
gs://mimiciii-1.4.physionet.org/INPUTEVENTS_CV.csv.gz
gs://mimiciii-1.4.physionet.org/INPUTEVENTS_MV.csv.gz
gs://mimiciii-1.4.physionet.org/LABEVENTS.csv.gz
gs://mimiciii-1.4.physionet.org/MICROBIOLOGYEVENTS.csv.gz
gs://mimiciii-1.4.physionet.org/NOTEEVENTS.csv.gz
gs://mimiciii-1.4.physionet.org/OUTPUTEVENTS.csv.gz
gs://mimiciii-1.4.physionet.org/PATIENTS.csv.gz
gs://mimiciii-1.4.physionet.org/PRESCRIPTIONS.csv.gz
gs://mimiciii-1.4.physionet.org/PROCEDUREEVENTS_MV.csv.gz
gs://mimiciii-1.4.physionet.org/PROCEDURES_ICD.csv.gz
gs://mimiciii-1.4.physionet.org/README.md
gs://mimiciii-1.4.physionet.org/SERVICES.csv.gz
gs://mimiciii-1.4.physionet.org/SHA256SUMS.txt
gs://mimiciii-1.4.physionet.org/TRANSFERS.csv.gz
gs://mimiciii-1.4.physionet.org/checksum_md5_unzipped.txt
gs://mimiciii-1.4.physionet.org/checksum_md5_zipped.txt
gs://mimiciii-1.4.physionet.org/mimic-iii-clinical-database-1.4.zip
```

## STEP 4: Create a new BigQuery dataset

### A) Create a new dataset for MIMIC-III version 1.4

In this example, we have chosen **mimic3_v1_4** as the dataset name.

```sh
bq mk --dataset --data_location US --description "MIMIC-III version 1.4" mimic3_v1_4
```

### B) Check the status of the dataset created

```sh
bq show mimic3_v1_4
```

---

## STEP 5: Download the table schemas

> NOTE: BigQuery has an option to automatically detect a table schema, but we found some issues with data type compatibility for seven tables (see below). For example, some columns received a different data type than listed on the MIMIC webpage (ex: string instead of integer). According to BigQuery documentation, "When auto-detection is enabled, BigQuery starts the inference process by selecting a random file in the data source and scanning up to 100 rows of data to use as a representative sample. BigQuery then examines each field and attempts to assign a data type to that field based on the values in the sample". (source: https://cloud.google.com/bigquery/docs/schema-detect).

The following errors occurred during the load with the option to automatically detect schemas:

- parse 'No' as double for field VALUE (CHARTEVENTS)
- parse 'G0272' as int for field CPT_CD (CPTEVENTS)
- parse 'V1869' as int for field ICD9_CODE (D_ICD_DIAGNOSES)
- parse '97.8000030518' as int for field AMOUNT (INPUTEVENTS_CV)
- parse '1535.4' as int for field TOTALAMOUNT (INPUTEVENTS_MV)
- parse '7.5' as int for field VALUE (OUTPUTEVENTS)
- parse '024665 041568 044488 043811 026076' as int for field GSN (PRESCRIPTIONS).

To fix these problems, we defined a schema for each table.

### A) Download the table schemas from the folder **schemas** to a local folder

> NOTE: "When you supply a JSON schema file, it must be stored in a locally readable location. You cannot specify a JSON schema file stored in Cloud Storage or Google Drive". (source: https://cloud.google.com/bigquery/docs/schemas)

BigQuery schemas are defined by JSON files. These files are an array of dictionaries with four fields: the name of the column (`name`), the data type of the column (`type`), an optional field restricting nulls (`mode`, default is NULLABLE), and an optional field providing a description of the column (`description`).

```json
{
    "mode": "NULLABLE",
    "name": "ROW_ID",
    "type": "INTEGER"
}
```

The information about the columns are compiled from several sources:

1. [The PostgreSQL build scripts](https://github.com/MIT-LCP/mimic-code/tree/main/mimic-iii/buildmimic/postgres)
2. [The MIMIC-III online documentation](https://mimic.physionet.org/about/mimic/)
3. [A schematic of the MIMIC-III database](https://mit-lcp.github.io/mimic-schema-spy/)

Currently all columns are set as NULLABLE as the tables will be used for searching/querying only and users with Viewer role should not be able to modify the tables (ex: insert/delete/update data). However, depending on your environment, you may need to set the mode REQUIRED for the appropriate columns.

We selected the type DATAETIME for all columns with dates and times. However, you could also use TIMESTAMP. As [discussed in the MIMIC-III documentation](https://mimic.physionet.org/mimicdata/time), columns with suffix DATE (ex: CHARTDATE) "will always have 00:00:00 as the hour, minute, and second values. This does not mean it was recorded at midnight: it indicates that we do not have the exact time, only the date". This is also true for other columns such DOB and DOD (patients table).

---

## STEP 6: Create tables and load the compressed files

### A) Create a script file (ex: upload_MIMIC3_v1_4.sh) and copy the code below.

You will need to change the **schema_local_folder** to match the path to the schemas on your local machine.

```sh
#!/bin/bash

# Initialize parameters
bucket="mimiciii-1.4.physionet.org"
dataset="mimic3_v1_4"
schema_local_folder="/home/user/mimic3_schema"

# Get the list of files in the bucket
FILES=$(gsutil ls gs://$bucket/*.csv.gz)

for file in $FILES
do

# Extract the table name from the file path (ex: gs://mimic3_v1_4/ADMISSIONS.csv.gz)
base=${file##*/}            # remove path
filename=${base%.*}         # remove .gz
tablename=${filename%.*}    # remove .csv

# Create table and populate it with data from the bucket
bq load --allow_quoted_newlines --skip_leading_rows=1 --source_format=CSV $dataset.$tablename gs://$bucket/$tablename.csv.gz $schema_local_folder/$tablename.schema.json

# Check for error
if [ $? -eq 0 ];then
    echo "OK....$tablename"
else
    echo "FAIL..$tablename"
fi

done
exit 0
```

This code will get the list of files in the bucket, and for each file, it will extract the table name (ex: ADMISSIONS). With the table name, the system executes the BigQuery load command `bq load` to create a table and load the data from the csv.gz file from the bucket using the specific schema from the local folder. The script will need (1) the name of the bucket where the compressed files are stored on Cloud Storage, (2) the name of the dataset to create and upload the tables, and (3) the path to the JSON file (schema) on your local machine.

During the load with the use of schemas the following error occurred:

- missing close double quote (") character (NOTEEVENTS)

This error is related to the source CSV file containing newlines within the string (ex: column TEXT). To fix it, we added the parameter `--allow_quoted_newlines` to the command `bq load`.

### B) Set the CHMOD to allow the file as executable (ex: 755), and execute the script file

```sh
./upload_MIMIC3_v1_4.sh
```

### C) Results of the upload process

The system will print **OK** or **FAIL** for each file processed. In case of failure, the system also prints a message with information about the error.

#### Upload OK

```sh
Waiting on bqjob_r7fe9abf4651b3ff3_000001620e9d13ff_1 ... (4s) Current status: DONE  
OK....ADMISSIONS
```

#### Upload FAIL

```sh
Waiting on bqjob_r3c23bb4d717cd8a9_000001620e9d5f6d_1 ... (496s) Current status: DONE
BigQuery error in load operation: Error processing job
'sandbox-nlp:bqjob_r3c23bb4d717cd8a9_000001620e9d5f6d_1': Error while reading data, error message: CSV table encountered too many errors, giving up. Rows: 63349; errors: 1. Please look into the error stream for more details.
Failure details:
- gs://mimiciii-1.4.physionet.org/CHARTEVENTS.csv.gz: Error while reading data,
error message: Could not parse 'No' as double for field VALUE
(position 8) starting at location 3353598526
FAIL..CHARTEVENTS
```


## STEP 7: Validate your dataset works

We can test a successful build by running a check query.

```sh
bq query --use_legacy_sql=False 'select CASE WHEN count(*) = 46520 THEN True ELSE
False end AS check from `mimic3_v1_4.patients`'
```

This verifies we have the expected row count in the patients table. It's further possible to check the row counts of the other tables: the [PostgreSQL checks script](../postgres/postgres_checks.sql) has the expected row counts for all tables.
