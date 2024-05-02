# Load MIMIC-IV into Athena

## Access Data
Gain a username and password to access MIMIC-IV from https://mimic.physionet.org/

## Load CSV files to S3

Run the following commands from your desktop, Cloud9 or an EC2 instance.

The commands below assumes that the machine running them has:
* AWS CLI installed
* IAM role that has s3:CreateBucket and s3:PutObject permissions.

In the lines below, replace:
* `<region>` with the aws region where your resources will be locates (ie us-west-2)
* `<username>` and `<password>` with your physionet username and password.  
* `<bucket>` with the name of your S3 bucket that will contain the data.

```bash
wget -r -N -c -np --user <username> --ask-password https://physionet.org/files/mimiciv/1.0/

export MIMICIV_BUCKET=<bucket>
aws configure set default.region <region>

aws s3 mb s3://$MIMICIV_BUCKET

cd physionet.org/files/mimiciv/1.0/

aws s3 cp core/admissions.csv.gz s3://$MIMICIV_BUCKET/csv/core/admissions/ 
aws s3 cp core/patients.csv.gz s3://$MIMICIV_BUCKET/csv/core/patients/
aws s3 cp core/transfers.csv.gz s3://$MIMICIV_BUCKET/csv/core/transfers/

aws s3 cp icu/chartevents.csv.gz s3://$MIMICIV_BUCKET/csv/icu/chartevents/
aws s3 cp icu/d_items.csv.gz  s3://$MIMICIV_BUCKET/csv/icu/d_items/
aws s3 cp icu/datetimeevents.csv.gz  s3://$MIMICIV_BUCKET/csv/icu/datetimeevents/ 
aws s3 cp icu/icustays.csv.gz  s3://$MIMICIV_BUCKET/csv/icu/icustays/
aws s3 cp icu/inputevents.csv.gz  s3://$MIMICIV_BUCKET/csv/icu/inputevents/
aws s3 cp icu/outputevents.csv.gz  s3://$MIMICIV_BUCKET/csv/icu/outputevents/
aws s3 cp icu/procedureevents.csv.gz s3://$MIMICIV_BUCKET/csv/icu/procedureevents/

aws s3 cp hosp/d_hcpcs.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/d_hcpcs/
aws s3 cp hosp/d_icd_diagnoses.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/d_icd_diagnoses/
aws s3 cp hosp/d_icd_procedures.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/d_icd_procedures/
aws s3 cp hosp/d_labitems.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/d_labitems/
aws s3 cp hosp/diagnoses_icd.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/diagnoses_icd/
aws s3 cp hosp/drgcodes.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/drgcodes/
aws s3 cp hosp/emar.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/emar/
aws s3 cp hosp/emar_detail.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/emar_detail/
aws s3 cp hosp/hcpcsevents.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/hcpcsevents/
aws s3 cp hosp/labevents.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/labevents/
aws s3 cp hosp/microbiologyevents.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/microbiologyevents/
aws s3 cp hosp/pharmacy.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/pharmacy/
aws s3 cp hosp/poe.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/poe/
aws s3 cp hosp/poe_detail.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/poe_detail/
aws s3 cp hosp/prescriptions.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/prescriptions/
aws s3 cp hosp/procedures_icd.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/procedures_icd/
aws s3 cp hosp/services.csv.gz s3://$MIMICIV_BUCKET/csv/hosp/services/
```

## Map schema

Use Athena to run the commands in schema.sql. Replace MIMICIV_BUCKET with your bucket name


## Create parquet data

Use Athena to run the commands in parquet.sql. Replace MIMICIV_BUCKET with your bucket name

