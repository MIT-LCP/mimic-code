---
title: "BigQuery"
linktitle: "BigQuery"
date: 2020-08-10
weight: 3
description: >
  Access MIMIC-IV on BigQuery
---

BigQuery is a columnar, distributed relational database management system. BigQuery accesses only the columns specified in the query, making it ideal for data analysis workflows. [Read more about BigQuery in Google's cloud documentation](https://cloud.google.com/bigquery/).

First, ensure you have been provisioned access to MIMIC-IV on BigQuery. See the [cloud page for instructions](/docs/access/cloud). Once you have been provisioned access to using MIMIC-IV on BigQuery, it's worthwhile to "pin" the dataset to see it on the BigQuery web tool.

1. Go to the BigQuery console: http://console.cloud.google.com/bigquery
2. On the left sidebar, next to "Resources", click "+ ADD DATA", followed by "Pin a project"
![Pin data for easy access](/img/cloud/bq/pin_data.png)
3. In the pop up window, type `physionet-data`, and click "PIN".
![Type physionet-data to pin the MIMIC-III data project](/img/cloud/bq/pin_physionet_data.png)
4. In the sidebar on the left, you should now see the `physionet-data` project. Click the arrow to the left of `physionet-data` to expand the project.
5. You should now see a number of projects. The relevant ones for MIMIC-IV are: `mimic_core`, `mimic_icu`, and `mimic_hosp`. If you see these datasets, you are ready to query the data! Try a simple query in the main dialogue box:

```sql
SELECT *
FROM `physionet-data.mimic_core.patients`
WHERE subject_id < 10000100
ORDER BY subject_id
```

The query should return some data, and your browser window should be similar to the below:

![Example output for the query](/img/cloud/bq/example_query.png)

At this point you are ready to use MIMIC on BigQuery!

A tutorial on using BigQuery to query MIMIC-III is available [here](/tutorials/intro-to-mimic-iii-bq.md).

Note that we have a number of pre-generated "views" of the data. These are available in the `mimic_derived` dataset which you are free to query. All code used to generate these views has been made openly available on the [MIMIC-IV code repository](https://github.com/MIT-LCP/mimic-iv/).

If you are having issues, see the [Troubleshooting section](#troubleshooting).

## Troubleshooting

### I get a pop-up about Terms of Service

![Agree to the terms of service](/img/cloud/bq/agree_tos.png)

You will need to agree to all GCP Terms of Service and adhere to their terms in order to use the data on BigQuery.

### When I go to BigQuery, it asks me to create a project

![Create a project on GCP](/img/cloud/bq/create_project.png)

Almost all of your interactions with GCP are associated with a *project*. Importantly, all billing for your usage must be allotted to a single project.
In order to use BigQuery you must have an activate project associated with your account. BigQuery offers a $300 free trial for first time users.

Create a project and select it as your activate project. If you've done this correctly, then the top bar of the Google console page should stop saying "Select a project", and instead have your project name. For example, in the below, I have selected the project `alistairewj`, which is now the activate project:

![Example of a working activate project](/img/cloud/bq/active_project.png)


### I can only see `eicu_crd_demo` and `mimiciii_demo`

These datasets are fully public, so the implication is that you have not been granted access to the full versions of the databases.
Please (1) double check you have entered your cloud information into your PhysioNet profile, verifying any e-mails as needed, and (2) requested access to the specific cloud project on its respective PhysioNet project page.

## I have a different issue

If none of the above have the answer, feel free to [raise an issue at the MIMIC-IV repository](https://github.com/MIT-LCP/mimic-iv/issues).
