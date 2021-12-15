# Testing MIMIC-IV code

Most of these tests focus on ensuring the concepts created in this repository are "correct". When working with messy data, it's very difficult to assert truth, but we can apply reasonable constraints, e.g. most patients in the ICU should have a heart rate measurement.

Broadly, the tests in this folder:

* ensure the SQL is syntactically valid by creating concepts in `mimic_derived_testing`
* verify the generated concepts match those in `mimic_derived`
* ensure concepts in `mimic_derived` match expectations

## Setting up for local testing

In order to run tests, we need a set of credentials with permission to (1) query `mimic_derived` and (2) create on `mimic_derived_testing`. This is done via the creation of a Google Cloud service account with the correct permissions on BigQuery. Service accounts are well described [in Google Cloud's IAM documentation](https://cloud.google.com/iam/docs/service-accounts). A service account with appropriate permissions can be created as follows:

```sh
gcloud iam service-accounts create sa-mimic-iv-testing-luban --display-name="sa-mimic-iv-testing-luban"
gcloud projects add-iam-policy-binding physionet-data --member='serviceAccount:sa-mimic-iv-testing-luban@physionet-data.iam.gserviceaccount.com' --role='roles/bigquery.jobUser'
```

Now that the service account has job permissions for BigQuery, we need to modify the BigQuery dataset permissions by (1) downloading the permissions as a JSON, (2) adding our service account as a reader/writer as appropriate, (3) reuploading the JSON permissions.
Details for provisioning access to a dataset are [described within the BigQuery documentation](
https://cloud.google.com/bigquery/docs/dataset-access-controls#controlling_access_to_a_dataset).
A simple python script is used to add the entry to the JSON (and verify it does not already exist), but this could also be done manually.

First, we add the service account as a reader of `mimic_derived`:

```sh
bq show --format=prettyjson physionet-data:mimic_derived > mimic_derived.json
python3 add_bq_role_to_user.py --file mimic_derived.json --user sa-mimic-iv-testing-luban@physionet-data.iam.gserviceaccount.com --role READER
bq update --source mimic_derived.json physionet-data:mimic_derived
```

Next, we add the account as a writer of `mimic_derived_testing`:

```sh
bq show --format=prettyjson physionet-data:mimic_derived_testing > mimic_derived.json
python3 add_bq_role_to_user.py --file mimic_derived.json --user sa-mimic-iv-testing-luban@physionet-data.iam.gserviceaccount.com --role WRITER
bq update --source mimic_derived.json physionet-data:mimic_derived_testing
```

Finally, we add the service account as a reader of the MIMIC-IV datasets:

```sh
for dataset in mimic_core mimic_hosp mimic_icu;
do
    bq show --format=prettyjson physionet-data:${dataset} > mimic_permissions.json
    python3 add_bq_role_to_user.py --file mimic_permissions.json --user sa-mimic-iv-testing-luban@physionet-data.iam.gserviceaccount.com --role READER
    bq update --source mimic_permissions.json physionet-data:${dataset}
done
```

With the account configured, we can create a key for the service, and download these credentials as a JSON.
**This is the only copy of the private key.** Don't lose it :)

```sh
gcloud iam service-accounts keys create "key.json" --iam-account sa-mimic-iv-testing-luban@physionet-data.iam.gserviceaccount.com
```

The tests will use the `key.json` file in the `tests/` folder by default, so you should now be able to run the tests!
