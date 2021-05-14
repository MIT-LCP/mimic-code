+++
title = "Downloading"
linktitle = "Downloading"
weight = 3
toc = false

[menu]
  [menu.main]
    parent = "About"

+++

# Working with MIMIC-CXR

MIMIC-CXR is over 4.7 TB, almost entirely due to the size of the DICOMs.
Users should strongly consider *not* downloading the data, and instead using it within Google Cloud Platform (GCP), which we support natively.
GCP does not charge for data transfer within a region in GCP ([see this page for more details about network charges.](https://cloud.google.com/storage/pricing#network-pricing)).
MIMIC-CXR is stored within a Google Cloud Bucket, and all GCP tools which interact with buckets will work with MIMIC-CXR.

You can browse MIMIC-CXR on GCP at the following link: https://console.cloud.google.com/storage/browser/mimic-cxr-2.0.0.physionet.org

You will need to be appropriately authenticated to view the data.

# Downloading

There are two mechanisms of downloading MIMIC-CXR:

1. (Recommended) `gsutil`: Google Cloud's command-line tool
2. wget over PhysioNet

While we provide users with the ability to freely download the data, it does come at substantial cost to us.
Please download the data with care, ideally only once for your group if multiple colleagues are collaborating.

## 1. gsutil

`gsutil` is a command-line tool for interacting with object stores.
You'll need to install `gsutil` locally and authenticate with the same Google account you have linked to your PhysioNet account.

See their instruction page for details on the install and configuration process: https://cloud.google.com/storage/docs/quickstart-gsutil

In order to access the data on GCP, your PhysioNet account must have your Google account e-mail, and you must [request access on the PhysioNet project page](https://physionet.org/content/mimic-cxr/#files). See the [cloud page for more detail on this process](/about/cloud).

Once you have `gsutil` installed and authenticated, you can download MIMIC-CXR as follows:

```
gsutil -m cp -r gs://mimic-cxr-2.0.0.physionet.org ./
```

... which will download all the data (4.7 TB) in the MIMIC-CXR project to your local folder. Note the use of the `-m` flag, which enables multiprocessing.


## 2. wget

You can use the command-line tool `wget` to download the data locally:

```
wget -r -N -c -np --user <PHYSIONETUSERNAME> --ask-password https://alpha.physionet.org/files/mimic-cxr/2.0.0/
```

... where you should replace `<PHYSIONETUSERNAME>` with your PhysioNet username, as appropriate.