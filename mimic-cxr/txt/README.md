# Code for working with the free-text reports

Useful code for working with the text of the radiology reports is provided in this folder.

This code was used to generate two files:

* mimic-cxr-2.0.0-chexpert.csv.gz
* mimic-cxr-2.0.0-negbio.csv.gz

## Extracting findings/impressions from the reports

The findings/impressions section of the reports can be considered as the "conclusion" of the radiologist.
The `create_section_files.py` script extracts these conclusions for each report text and outputs them to a folder of CSVs, with about 10,000 reports per CSV.

The script can be run (from this folder) as follows:

`python create_section_files.py --reports_path /db/mimic-cxr/files --output_path /db/mimic-cxr/mimic-cxr-sections`

... where you should replace `/db/mimic-cxr/mimic-cxr-reports/files` with the location of your MIMIC-CXR files folder.

## CheXpert

Instructions for generating CheXpert annotations from the reports are available [in the chexpert subfolder](/txt/chexpert).

## NegBio

Instructions for generating CheXpert annotations from the reports are available [in the negbio subfolder](/txt/negbio).