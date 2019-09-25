# Code for working with the reports

Useful code for working with the reports is provided in this folder.

## Extracting findings/impressions from the reports

The findings/impressions section of the reports can be considered as the "conclusion" of the radiologist.
The `create_section_files.py` script extracts these conclusions for each report text and outputs them to a folder of CSVs, with about 10,000 reports per CSV.

The script can be run (from this folder) as follows:

`python create_section_files.py --reports_path /db/mimic-cxr/mimic-cxr-reports/files --output_path /db/mimic-cxr/mimic-cxr-sections`

... where you should replace `/db/mimic-cxr/mimic-cxr-reports/files` with the location of your MIMIC-CXR files folder.

## CheXpert

Instructions for generating CheXpert annotations from the reports are available [in the chexpert subfolder](/reports/chexpert).

## NegBio

Instructions for generating CheXpert annotations from the reports are available [in the negbio subfolder](/reports/negbio).