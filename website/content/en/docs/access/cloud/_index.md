---
title: "Cloud"
linktitle: "Cloud"
date: 2020-11-25
weight: 1
description: >
  Access MIMIC-IV on the Cloud
---

MIMIC-IV is made available via [PhysioNet](https://physionet.org/content/mimiciv/). Beyond directly downloading the dataset from PhysioNet, there are a few mechanisms for accessing the data:

* Accessing the data in a Google Cloud storage bucket
* Accessing the data in BigQuery

We **highly** recommend using MIMIC-IV in BigQuery for the following reasons:

* No setup required
* Updates will be integrated into BigQuery when they are available
* Derived concepts from the [MIMIC-IV code repository](https://www.github.com/MIT-LCP/mimic-iv) are precomputed and available on the `mimic_derived` dataset

If absolutely necessary, it is possible to download the data from a Google cloud bucket; instructions are provided at the end of the document.
Please do keep in mind that the PhysioNet team is covering the cost of downloading the dataset.

## Accessing data on the cloud

There are three steps to accessing data on the cloud:

1. Link your cloud account to your PhysioNet profile
2. Request access to the cloud resource
3. Log-in to the appropriate service and navigate to the resource

These steps assume you are already credentialed and have signed the data use agreement for MIMIC-IV.
If you have not, [read this page for instructions on gaining access to MIMIC-IV](/access).

## Accessing MIMIC-IV on the cloud

Now that your cloud credentials are available in PhysioNet, you can request access to databases within those cloud systems.
Cloud access to PhysioNet projects such as MIMIC-IV and MIMIC-III are managed independently. You must request access to the cloud systems via their project pages (access is provisioned instantly for credentialed users who have signed the DUA).

For MIMIC-IV, go to the [MIMIC-IV PhysioNet project page](https://physionet.org/content/mimiciii/1.4/).

Once there, scroll to the bottom to the "Files" section.
*If* the page shows a restricted-access warning, you need to [get access to MIMIC-IV](/access).
Otherwise, you should see the following:

![Methods for accessing MIMIC-IV](/img/cloud/mimic_files.png)

The following describes the access options listed above in the order they are listed:

1. Downloading the data as one large zip file
  * This downloads the data directly from the PhysioNet servers.
2. **Cloud**: Adds your GCP e-mail to the access list for GCP BigQuery.
  * This option adds the GCP e-mail in your PhysioNet account to a BigQuery access list; it's required in order to use the data in BigQuery.
3. **Cloud**: Adds your GCP e-mail to the access list for downloading the data from a GCP Storage Bucket.
  * This option adds the GCP e-mail in your PhysioNet account to a GCP access list; it's required in order to download the data from a storage bucket on GCP.
4. TBD. AWS is not yet available for MIMIC-IV.
5. TBD. AWS is not yet available for MIMIC-IV.
6. Provides a command for downloading the data from PhysioNet as individual CSV files using `wget` (when compared to the image above, your command will have a distinct username).
  * This downloads the data directly from PhysioNet servers, but in their raw (usually uncompressed) form.

<!--
4. **Cloud**: A public page for viewing the data description in the AWS Open Data Repository.
  * This forwards you to the AWS Open Data Repository listing of the data. For information on how to use AWS, we [recommend reading this tutorial](https://aws.amazon.com/blogs/big-data/perform-biomedical-informatics-without-a-database-using-mimic-iii-data-and-amazon-athena/).
5. **Cloud**: Adds your AWS account ID to the access list for AWS.
  * This is necessary in order to access the data via AWS services. For information on how to use AWS, we [recommend reading this tutorial](https://aws.amazon.com/blogs/big-data/perform-biomedical-informatics-without-a-database-using-mimic-iii-data-and-amazon-athena/).
-->

Options #1, #3, #4, and #6 all provide the ability to download the data locally.
For users interested in using BigQuery, you can read the [getting started with using MIMIC-IV on BigQuery page](/docs/access/bigquery) and subsequently read the [querying tutorial on BigQuery](/docs/tutorials/bigquery).

Once you have access to MIMIC-IV, we highly recommend you read the [database introduction](/docs/overview/).
