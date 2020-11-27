---
title: "Linking your cloud account"
linktitle: "Link"
date: 2020-11-27
weight: 1
description: >
  How to connect your PhysioNet account to a cloud account.
---

MIMIC is available for use via two cloud platforms: Google Cloud Platform (GCP) and Amazon Web Services (AWS). Access to these services is directly controlled via your PhysioNet account.

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

## Linked account

Once you have successfully linked a cloud account to your PhysioNet profile, the next step is to [request access to MIMIC-IV for your cloud account](/access/cloud/request).