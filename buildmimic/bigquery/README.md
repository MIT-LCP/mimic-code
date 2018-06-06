# Installing MIMIC3 v1.4 to BigQuery

Following are the steps to create the MIMIC-III dataset on BigQuery and load the source files (.csv.gz) downloaded from Physionet.

**IMPORTANT**: Only users with approved Physionet Data Use Agreement (DUA) should be given access to the MIMIC dataset via BigQuery or Cloud Storage. If you don't have access to MIMIC, follow the instructions [here](https://mimic.physionet.org/gettingstarted/access/) to request access.

---
## STEP 1: Download the MIMIC-III Source files

> NOTE: According to the BigQuery documentation (Last updated May 4, 2018.), "BigQuery can load uncompressed files significantly faster than compressed files because uncompressed files can be read in parallel. Because uncompressed files are larger, using them can lead to bandwidth limitations and higher Google Cloud Storage costs for data staged in Google Cloud Storage prior to being loaded into BigQuery". The site also states that "currently, there is no charge for loading data into BigQuery".

For this tutorial, we will proceed using the compressed files (.csv.gz). However, if you want to keep the files for users that may want direct access to the CSV files via R or Python, you could unzip the compressed files to your load machine and upload them instead.  

### A) Download all MIMIC-III csv.gz files from [Physionet.org](https://mimic.physionet.org/) to your local machine. 


---
## STEP 2: Install Google Cloud SDK

### A) Install `google-cloud-sdk`.

```
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

sudo apt-get update && sudo apt-get install google-cloud-sdk
```

### B) Start Google Cloud. The system should open an Internet browser and ask you to login to Google Cloud Platform and select a default project.

```
gcloud init
```

---
## STEP 3: Upload the MIMIC-III files to a bucket on Google Cloud Storage

> NOTE: According to the Cloud Storage webpage, “When transferring data from an on-premises location, use gsutil” (source: https://cloud.google.com/storage/transfer). Alternatively, you can use the Web UI to create the bucket and upload the files.

### A) Create a new bucket on Cloud Storage. For example: **mimic3_v1_4**

```
gsutil mb gs://mimic3_v1_4
```

### B) Copy all csv.gz files from the local machine to the bucket created above. Navigate to the folder where you downloaded the gzip files and execute the following command to copy the files. 

```
gsutil cp *.csv.gz gs://mimic3_v1_4
```  

### C) Check the content of the bucket. 

```
gsutil ls gs://mimic3_v1_4
```
It should list all 26 MIMIC files (.csv.gz). 
```
gs://mimic3_v1_4/ADMISSIONS.csv.gz
gs://mimic3_v1_4/CALLOUT.csv.gz
gs://mimic3_v1_4/CAREGIVERS.csv.gz
gs://mimic3_v1_4/CHARTEVENTS.csv.gz
gs://mimic3_v1_4/CPTEVENTS.csv.gz
gs://mimic3_v1_4/DATETIMEEVENTS.csv.gz
gs://mimic3_v1_4/DIAGNOSES_ICD.csv.gz
gs://mimic3_v1_4/DRGCODES.csv.gz
gs://mimic3_v1_4/D_CPT.csv.gz
gs://mimic3_v1_4/D_ICD_DIAGNOSES.csv.gz
gs://mimic3_v1_4/D_ICD_PROCEDURES.csv.gz
gs://mimic3_v1_4/D_ITEMS.csv.gz
gs://mimic3_v1_4/D_LABITEMS.csv.gz
gs://mimic3_v1_4/ICUSTAYS.csv.gz
gs://mimic3_v1_4/INPUTEVENTS_CV.csv.gz
gs://mimic3_v1_4/INPUTEVENTS_MV.csv.gz
gs://mimic3_v1_4/LABEVENTS.csv.gz
gs://mimic3_v1_4/MICROBIOLOGYEVENTS.csv.gz
gs://mimic3_v1_4/NOTEEVENTS.csv.gz
gs://mimic3_v1_4/OUTPUTEVENTS.csv.gz
gs://mimic3_v1_4/PATIENTS.csv.gz
gs://mimic3_v1_4/PRESCRIPTIONS.csv.gz
gs://mimic3_v1_4/PROCEDUREEVENTS_MV.csv.gz
gs://mimic3_v1_4/PROCEDURES_ICD.csv.gz
gs://mimic3_v1_4/SERVICES.csv.gz
gs://mimic3_v1_4/TRANSFERS.csv.gz
```

---
## STEP 4: Create a new BigQuery dataset

### A) Create a new dataset for MIMIC3 version 1.4. For example. **MIMIC3_V1_4**. 

```
bq mk --dataset --data_location US --description "MIMIC-III version 1.4" MIMIC3_V1_4
```

### B) Check the status of the dataset created. 

```
bq show MIMIC3_V1_4
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

### A) Download the table schemas from the folder **schemas** to a local folder.

> NOTE: "When you supply a JSON schema file, it must be stored in a locally readable location. You cannot specify a JSON schema file stored in Cloud Storage or Google Drive". (source: https://cloud.google.com/bigquery/docs/schemas)

Each table has its own JSON file with information about the columns to be loaded, and for each colum we informed three parameters: mode, name and type. All columns are set as NULLABLE. This is optional and if not informed, the system will set NULLABLE as default.

```
{
    "mode": "NULLABLE",
    "name": "ROW_ID",
    "type": "INTEGER"
}
```

The information about the columns are compiled from several sources:
1. https://github.com/MIT-LCP/mimic-code/tree/master/buildmimic
2. https://mimic.physionet.org/about/mimic/
3. https://mit-lcp.github.io/mimic-schema-spy/

We didn't set any column as REQUIRED (i.e., NULL values are not allowed) because the tables will be used for searching/querying only and users with Viewer role should not be able to modify the tables (ex: insert/delete/update data). However, depending on your environment, you may need to set the mode REQUIRED for the appropriate columns. 

We selected the type DATAETIME for all columns with dates and times. However, you could also use TIMESTAMP. Columns with suffix DATE (ex: CHARTDATE) “will always have 00:00:00 as the hour, minute, and second values. This does not mean it was recorded at midnight: it indicates that we do not have the exact time, only the date” (source: https://mimic.physionet.org/mimicdata/time). This is also true for other columns such DOB and DOD (Patients table).

---
## STEP 6: Create tables and load the compressed files

### A) Create a script file (ex: upload_MIMIC3_v1_4.sh) and copy the code below. Change the **schema_local_folder** to match the path to the schemas on your local machine.

```
#!/bin/bash

# Initialize parameters
bucket="mimic3_v1_4"
dataset="MIMIC3_V1_4"
schema_local_folder="/home/user/mimic3_schema"

# Get the list of files in the bucket
FILES=$(gsutil ls gs://$bucket)

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

### B) Set the CHMOD to allow the file as executable (ex: 755), and execute the script file.

```
./upload_MIMIC3_v1_4.sh
```

### C) Results of the upload process. 

The system will print **OK** or **FAIL** for each file processed. In case of failure, the system also prints a message with information about the error.

#### Upload OK

```
Waiting on bqjob_r7fe9abf4651b3ff3_000001620e9d13ff_1 ... (4s) Current status: DONE  
OK....ADMISSIONS
```

#### Upload FAIL

```
Waiting on bqjob_r3c23bb4d717cd8a9_000001620e9d5f6d_1 ... (496s) Current status: DONE   
BigQuery error in load operation: Error processing job
'sandbox-nlp:bqjob_r3c23bb4d717cd8a9_000001620e9d5f6d_1': Error while reading data, error message: CSV table encountered too many errors, giving up. Rows: 63349; errors: 1. Please look into the error stream for more details.
Failure details:
- gs://mimic3_v1_4/CHARTEVENTS.csv.gz: Error while reading data,
error message: Could not parse 'No' as double for field VALUE
(position 8) starting at location 3353598526
FAIL..CHARTEVENTS
```

---
## STEP 7: Delete the bucket

### A) If the bucket is no longer required, you can delete the compressed files and the bucket with the following commands.

```
gsutil rm gs://mimic3_v1_4/*.csv.gz 
gsutil rb gs://mimic3_v1_4
```
