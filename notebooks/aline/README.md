# Reproducing the indwelling arterial catheter study (aline study)

This folder contains code for reproducing a study on indwelling arterial catheters:

> Hsu DJ, Feng M, Kothari R, Zhou H, Chen KP, Celi LA. The association between indwelling arterial catheters and mortality in hemodynamically stable patients with respiratory failure: a propensity score analysis. CHEST Journal. 2015 Dec 1;148(6):1470-6.

The study showed, in the MIMIC-II database, that after adjustment for various confounders, indwelling arterial catheters were not associated with a mortality benefit.

The code here reproduces this study in the MIMIC-III database. This involved many technical changes due to schema differences and data differences between MIMIC-II and MIMIC-III. As MIMIC-III covers four additional years, the cohort extracted here is larger than that reported in the study.

# Requirements

There are a number of prerequesites to running this code:

* an installation of MIMIC-III in a PostgreSQL database
* Python 2.7 with the numpy, pandas, matplotlib, and psycopg2 packages
* Jupyter with a Python 2 kernel
* R with the `Matching`, `pROC`, `MASS` libraries

# Running the study

The study can be reproduced by:

1. Running the `aline.ipynb` file - this notebook generates the data (using the SQL files in this directory) and saves a single dataframe to CSV
2. Running the `aline_propensity_score.Rmd` file - this R markdown file uses the above CSV to create a propensity score and calculate the mortality difference between matched pairs

# Slight modifications

There are a few minor differences between our reproduction and the original study.

* the original study subselected variables using a genetic algorithm, whereas we simply use the final set of variables they report
* we did not include PO2 and PCO2 in the propensity score
* we removed patients based on hospital service, not ICU service
