# CheXpert

This folder provides code and instructions for running the CheXpert NLP tool on MIMIC-CXR.

## Requirements

1. Sectioned report CSVs using the create_section_files.py script. See the [report folder](/report/) for details.
2. chexpert-labeler installed. See [the CheXpert repository](https://github.com/stanfordnlp/chexpert/) for details.

# Running CheXpert

Open up a terminal in this folder.

1. `conda activate chexpert-label` - activates the environment
2. `export PYTHONPATH=/home/alistairewj/git/NegBio` - necessary for running chexpert
3. `export REPORT_PATH=/db/mimic-cxr/mimic-cxr-sections` - tells the script where your sectioned .csv files are
4. `export CHEXPERT_PATH=/home/alistairewj/git/chexpert-labeler` - we need to know the chexpert folder to set the path for the .txt files that define mentions, negations, etc.
5. `sh run_chexpert_on_files.sh`
