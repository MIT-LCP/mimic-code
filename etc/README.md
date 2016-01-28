# Contents of this folder

This folder contains miscellaneous scripts used as staging tables for useful clinical concepts, e.g. severity scores. Each script generates a materialized view of the data.

## auroc.sql

This file calculates the area under the receiver operator characteristic curve (AUROC) for a set of predictions, `PRED`, given a set of targets, `TAR`. The AUROC is a useful measure of the discrimination of a set of predictions.

# Subfolders

## firstday

The first day subfolder contains scripts used to calculate various clinical concepts on the first day of a patient's admission to the ICU. These values are usually used in the calculation of severity scores.


# Last updated

This folder was last updated January 26th, 2016.
