---
title: "Cloud"
linktitle: "Cloud"
date: 2020-08-10
weight: 2
description: >
  Access MIMIC-IV on the Cloud
---

We are primarily sharing MIMIC-IV via BigQuery. We highly recommend using BigQuery as updates to MIMIC-IV will be uploaded to BigQuery as they occur. If absolutely necessary, it is possible to download the data from a Google cloud bucket; instructions are provided at the end of the document.

# Cloud access

MIMIC is available for use via two cloud platforms: Google Cloud Platform (GCP) and Amazon Web Services (AWS). Access to these services is directly controlled via your PhysioNet account.

In order to use MIMIC on the cloud, you must:

1. Be an approved user on PhysioNet. [Read this page for instructions on gaining access to MIMIC-IV.](/access)
2. Add cloud credentials to your PhysioNet profile
3. Request access on the MIMIC-IV PhysioNet project page

We will assume you are a credentialed user on PhysioNet and have signed the MIMIC data use agreement.

## Adding cloud credentials

Go to your PhysioNet profile page.

![Profile page on PhysioNet](/img/cloud/profile.png)

Click "Emails":

![Navigate to the e-mails page](/img/cloud/emails.png)

For GCP access, ensure that one of your e-mails is a Google account. This can either be a gmail account (as in the picture), or a G Suite account if your organization is a member of G Suite. You can add an e-mail at the bottom of the page:

![Navigate to the Cloud page](/img/cloud/add_email.png)

You will need to verify your e-mail address before continuing (note: e-mail addresses are only used for GCP access, and not for AWS access).

Once you have a verified e-mail address ready, navigate to the "Cloud" page on PhysioNet.

![Navigate to the Cloud page](/img/cloud/cloud_page.png)

You should see two options on this page: one for GCP, and one for AWS.

![Profile cloud credentials](/img/cloud/credentials.png)

For GCP, click the drop down menu and set your GCP e-mail to the Google account you provided in the earlier step.

For AWS, add your AWS canonical ID. This is *not your e-mail*. It is a numeric identifier that can be found in your AWS cloud profile. [Click here to go to your AWS profile page](https://console.aws.amazon.com/billing/home?#/account). Then look for your "Account Id":

![AWS ID](/img/cloud/aws/aws_id.png)

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

## Documentation

Once you have access to MIMIC-IV, we highly recommend you read the [database introduction](/mimic-iv). Subsequent table by table documentation is [available online](/tables/overview.md).
