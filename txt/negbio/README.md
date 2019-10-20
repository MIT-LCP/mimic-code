# NegBio

This folder provides code and instructions for running the NegBio NLP tool on MIMIC-CXR.

## Requirements

1. Sectioned report CSVs using the create_section_files.py script. See the [txt folder](/txt/) for details.
    * From this, note the path containing the CSVs, e.g. `/data/mimic-cxr/sections`. This folder should have 22 files, with filenames `mimic_cxr_000.csv`, `mimic_cxr_001.csv`, ...
2. We use the `conda` manager to create a virtual environment to run the code in. To use `conda`, you will need to install [Miniconda](https://docs.conda.io/en/latest/miniconda.html) or [Anaconda](https://www.anaconda.com/) (Miniconda is a light-weight alternative of Anaconda).

## Installation

Open up a terminal in this folder.

1. Create the virtual environment

`conda env create -f environment.yml`

2. Copy the MIMIC-CXR specific NegBio code

`git clone --single-branch --branch MIMIC-CXR https://github.com/ncbi-nlp/NegBio.git`

3. Change into the NegBio folder

`cd NegBio`

4. Add necessary environment variables. **At a minimum, be sure to edit the INPUT_FILES variable**.

```
export OUTPUT_DIR=../
export OUTPUT_LABELS=$OUTPUT_DIR/mimic_cxr_negbio_labels.csv
export INPUT_FOLDER=/data/mimic-cxr/sections
export INPUT_FILES=`ls ${INPUT_FOLDER}/mimic_cxr_*.csv`
```

5. Run the bash script which calls NegBio

```
bash run_negbio_on_files.sh
```
