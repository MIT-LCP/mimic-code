# Notebooks to reproduce the results of the paper *Data-driven Curation Process for describing the Blood Glucose Management in the Intensive Care Unit*

All code used for data extraction, processing, and visualization was made available online (two JUPYTER notebooks (Python 3.7) and a MATLAB’s Live Script) in the MIMIC Code Repository for reproducibility and code reuse.

The SQL code for extracting the glucose readings (`glucose_readings.sql`) and insulin events (`insulin.sql`) are located in the path `mimic-code/concepts/cookbook/`. The queries were performed on Google’s BigQuery. The two JUPYTER notebooks can be run on Google’s Colaboratory. The user should have installed either JUPYTER notebook or JUPYTER lab and dependencies when running these notebooks locally. The Live Script requires at least MATLAB version R2019b.
