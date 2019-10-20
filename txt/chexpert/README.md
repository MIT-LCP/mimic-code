# CheXpert

This folder provides code and instructions for running the CheXpert NLP tool on MIMIC-CXR.

## Requirements

1. Sectioned report CSVs using the create_section_files.py script. See the [txt folder](/txt/) for details.
    * From this, note the path containing the CSVs, e.g. `/data/mimic-cxr/sections`. This folder should have 22 files, with filenames `mimic_cxr_000.csv`, `mimic_cxr_001.csv`, ...
2. We use the `conda` manager to create a virtual environment to run the code in. To use `conda`, you will need to install [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or [Anaconda](https://www.anaconda.com/) (Miniconda is a light-weight alternative of Anaconda).

# Running CheXpert

Open up a terminal in this folder.

1. Install the environment

2. Activate the environment

`conda activate chexpert-label`

3. Clone the chexpert repository as we need phrases from the folder

`git clone https://github.com/stanfordmlgroup/chexpert-labeler`

4. Add necessary environment variables. **At a minimum, be sure to edit the REPORT_PATH variable**.

```
export REPORT_PATH=/db/mimic-cxr/mimic-cxr-sections  # where the mimic_cxr_###.csv files are
export CHEXPERT_PATH=chexpert-labeler  # cloned chexpert repository
```

5. Run the bash script which calls CheXpert

`sh run_chexpert_on_files.sh`

6. Aggregate the labels together into a single file


