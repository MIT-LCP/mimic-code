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

`git clone --single-branch --branch MIMIC-CXR https://github.com/ncbi-nlp/NegBio.git negbio-mimic-cxr`

3. For reproducibility, checkout the exact commit hash of NegBio that was used generate these labels.

`cd negbio-mimic-cxr; git checkout 962690b6789920fb0abab4fe05fc8ce6bc1a349d; cd ..`

3. Run the bash script which calls NegBio. The first argument should be the location of the sectioned files. The second argument should be the path to NegBio on the MIMIC-CXR branch.
  * This script will loop through each file in first argument, `BASE_FOLDER`
  * The script runs NegBio on files which match the pattern `mimic_cxr_####.csv`
  * Results are output to `BASE_FOLDER/mimic_cxr_####/`, i.e. in a folder of the same name (minus the .csv extension)

**Warning: running this on all of MIMIC-CXR will generate ~15 GB of space on your hard drive**.

```
bash run_negbio_on_files.sh /db/mimic-cxr/sections negbio-mimic-cxr
```