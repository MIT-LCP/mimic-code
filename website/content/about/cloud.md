+++
title = "Cloud"
linktitle = "Cloud"
weight = 3
toc = false

[menu]
  [menu.main]
    parent = "About"

+++

# MIMIC-IV

We are primarily sharing MIMIC-IV via BigQuery. We highly recommend using BigQuery as we plan to roll out updates to it over the coming months, and staying on the platform will greatly simplify use of the data. If absolutely necessary, it is possible to download the data from a Google cloud bucket; instructions are provided at the end of the document.

## Sources of data

### BigQuery

BigQuery is a columnar, distributed relational database management system. BigQuery accesses only the columns specified in the query, making it ideal for data analysis workflows. [Read more about BigQuery on Google.](https://cloud.google.com/bigquery/)

BigQuery is available [via the web browser](https://console.cloud.google.com/bigquery).

### Adding physionet-data

### BigQuery Datasets

BigQuery has a hierarchy as follows: each project can contain one or more datasets, and each dataset can contain one or more tables. The rough equivalent for a project is a relational database, and the equivalent of a dataset is a schema. Unlike MIMIC-III, MIMIC-IV has multiple datasets (schemas). This allows users to immediately know the source of the data, and simplifies understanding of the database structure.

A tutorial on using BigQuery [is available online](/about/bigquery).

<!--
Once you have access to MIMIC-IV, we highly recommend you read the [database introduction](/mimic-iv). 
-->

Subsequent table by table documentation is available online:

* [core](/datasets/core)
* [hosp](/datasets/hosp)
* [icu](/datasets/icu)
* [ed](/datasets/ed)
* [cxr](/datasets/cxr)

## Google Cloud bucket

Google stores data in ``buckets''. Access to these buckets is controlled using the same mechanism for access control as BigQuery. There are a few methods of downloading data from buckets. We suggest one of two approaches: downloading the data via your web browser, or using the Google Cloud tools.

### Web browser download

1. Navigate to the bucket: https://console.cloud.google.com/storage/browser/mimic-iv.physionet.org
2. Ensure you are logged into the correct Google account. Use the top right icon to view and/or change your current activate Google account. We only provide access to the account given to us.
3. Select each file in turn, and click "Download".

While slightly tedious, there are less than 20 files, and so this process is reasonably done.

### Google cloud tools (gsutil)

1. Download the Google Cloud SDK and follow the instructions to install it: https://cloud.google.com/storage/docs/gsutil_install
2. Open a terminal
3. Ensure you have initialized the SDK: `gcloud init`
4. (Optional) Authenticate using the approved Google account: `gsutil auth`
    * This is not required if you authenticated with the correct account during `gcloud init`
5. Run the below shell commands (or, copy them into a script to run). All commands are of the form: `gsutil -m cp <source data> ./`, i.e. they copy to the current folder.

```sh
# core
gsutil -m cp gs://mimic-iv.physionet.org/core/patients.csv.gz gs://mimic-iv.physionet.org/core/admissions.csv.gz gs://mimic-iv.physionet.org/core/stays.csv.gz gs://mimic-iv.physionet.org/core/services.csv.gz ./

# hospital
gsutil -m cp gs://mimic-iv.physionet.org/hosp/d_hcpcs.csv.gz gs://mimic-iv.physionet.org/hosp/d_icd_diagnoses.csv.gz gs://mimic-iv.physionet.org/hosp/d_icd_procedures.csv.gz gs://mimic-iv.physionet.org/hosp/d_labitems.csv.gz gs://mimic-iv.physionet.org/hosp/d_micro.csv.gz gs://mimic-iv.physionet.org/hosp/diagnoses_icd.csv.gz gs://mimic-iv.physionet.org/hosp/drgcodes.csv.gz gs://mimic-iv.physionet.org/hosp/hcpcsevents.csv.gz gs://mimic-iv.physionet.org/hosp/microbiologyevents.csv.gz gs://mimic-iv.physionet.org/hosp/procedures_icd.csv.gz ./

# big hospital tables (>1 GB compressed) that are sharded
gsutil -m cp gs://mimic-iv.physionet.org/hosp/emar_*.csv.gz gs://mimic-iv.physionet.org/hosp/emar_detail_*.csv.gz gs://mimic-iv.physionet.org/hosp/labevents_*.csv.gz ./

# ICU
gsutil -m cp  gs://mimic-iv.physionet.org/icu/d_items.csv.gz gs://mimic-iv.physionet.org/icu/datetimeevents.csv.gz gs://mimic-iv.physionet.org/icu/icustays.csv.gz  gs://mimic-iv.physionet.org/icu/outputevents.csv.gz gs://mimic-iv.physionet.org/icu/procedureevents.csv.gz ./

# big ICU tables (>1 GB compressed) that are sharded
gsutil -m cp gs://mimic-iv.physionet.org/icu/chartevents_*.csv.gz gs://mimic-iv.physionet.org/icu/inputevents_*.csv.gz ./

# ED
gsutil -m cp gs://mimic-iv.physionet.org/ed/main.csv.gz gs://mimic-iv.physionet.org/ed/medrecon.csv.gz gs://mimic-iv.physionet.org/ed/pyxis.csv.gz gs://mimic-iv.physionet.org/ed/triage.csv.gz gs://mimic-iv.physionet.org/ed/vitalsign.csv.gz gs://mimic-iv.physionet.org/ed/vitalsign_hl7.csv.gz ./

# CXR
gsutil -m cp gs://mimic-iv.physionet.org/cxr/cxr/record_list.csv.gz gs://mimic-iv.physionet.org/cxr/cxr/study_list.csv.gz ./
```

Note this script copies into the local folder.

# Documentation

Once you have access to MIMIC-IV, we highly recommend you read the [database introduction](/mimic-iv). Subsequent table by table documentation is [available online](/tables/overview.md).
