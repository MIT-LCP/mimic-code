# MIMIC-III

## Brief introduction

The repository consists of a number of Structured Query Language (SQL) scripts which build the MIMIC-III database in a number of systems and extract useful concepts from the raw data.
Jupyter notebooks are also provided which detail analyses performed on MIMIC-III.

The repository is organized as follows:

* [benchmark](/mimic-iii/benchmark) - Various speed tests for indices
* [buildmimic](/mimic-iii/buildmimic) - Scripts to build MIMIC-III in a relational database management system (RDMS), in particular [postgres](/buildmimic/postgres) is our RDMS of choice
* [concepts](/mimic-iii/concepts) - Useful views/summaries of the data in MIMIC-III, e.g. demographics, organ failure scores, severity of illness scores, durations of treatment, easier to analyze views, etc. The paper above describes these in detail, and a README in the subfolder lists concepts generated.
* [notebooks](/mimic-iii/notebooks) - A collection of R markdown and Jupyter notebooks which give examples of how to extract and analyze data
* [notebooks/aline](/mimic-iii/notebooks/aline) - An entire study reproduced in the MIMIC-III database - from cohort generation to hypothesis testing
* [notebooks/aline-aws](/mimic-iii/notebooks/aline-aws) - As above, [launchable immediately on AWS](#launch-mimic-iii-in-aws)
* [tests](/mimic-iii/tests) - You should always have tests!
* [tutorials](/mimic-iii/tutorials) - Similar to the notebooks folder, but focuses on explaining concepts to new users

\* A Makefile build system has been created to facilitate the building of the MIMIC database, and optionally contributed views from the community. Please refer to the [Makefile guide](/mimic-iii/Makefile.md) for more details.
