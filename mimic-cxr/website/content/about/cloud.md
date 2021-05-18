+++
date = "2015-09-01T19:33:17-04:00"
title = "Cloud"
linktitle = "Cloud"
weight = 4
toc = false

[menu]
  [menu.main]
    parent = "About"

+++

# MIMIC-CXR on the Cloud

MIMIC-CXR has been made available on Google Cloud Platform (GCP).
You can use all GCP products to work with the data. You can also integrate tools from other platforms with GCP.

In order to use MIMIC on the cloud, you must:

1. Be a credentialed user on PhysioNet. [Read this page for instructions on how to become credentialed.](/about/access)
2. Add cloud credentials to your PhysioNet profile
    * We will only use your provided Google account address to provision access: we do not share any other information in your PhysioNet profile with Google.
3. Request access on the MIMIC-CXR PhysioNet project page

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

Click the drop down menu and set your GCP e-mail to the Google account you provided in the earlier step.

## Accessing MIMIC-CXR on the cloud

Now that your GCP account is in your PhysioNet profile, you can request access to MIMIC-CXR on GCP via its PhysioNet project page.
Go to the [MIMIC-CXR PhysioNet project page](https://physionet.org/content/mimic-cxr/).

Once there, scroll to the bottom to the "Files" section.
*If* the page shows a restricted-access warning, you need to [get access to MIMIC-CXR](/about/access) or sign the data use agreement for this project.
Otherwise, you should see the following:

![Methods for accessing MIMIC-CXR](/img/cloud/mimic_cxr_files.png)

The following describes the access options listed above in the order they are listed:

* Adds your GCP e-mail to the access list for downloading the data from a GCP Storage Bucket.
* Provides a command for downloading the data from PhysioNet as individual CSV files using `wget` (your command will have a different username).

Click the "Request access" button to request access to the project on the Cloud.

If successful, you should be taken to the top of the page with a notification in green as below:

![Successful](/img/cloud/gcp_successful.png)

... where `<your email>` should be the e-mail address you requested access with.
You will also receive an e-mail with some instructions on using GCP's storage browser.

Once you've successfully been given access, you can navigate MIMIC-CXR at the following link:
https://console.cloud.google.com/storage/browser/mimic-cxr-2.0.0.physionet.org