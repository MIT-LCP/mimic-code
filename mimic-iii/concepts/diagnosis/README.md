# ccs_dx

The Clinical Classification Software (CCS) categorizes ICD-9 coded diagnoses into clinically meaningful groups. The categorization was developed by the Agency for Healthcare Research and Quality (AHRQ). More detail can be found on the AHRQ website: https://www.hcup-us.ahrq.gov/tools_software.jsp

The `ccs_multi_dx.csv.gz` data file must be uploaded to `physionet-data.mimiciii_derived.ccs_multi_dx`.

The BigQuery schema definition is available in this folder as [ccs_multi_dx.json](/ccs_multi_dx.json).

## Creation of the ccs_multi_dx.csv.gz file

Download the original file from CCS: 

```
wget https://www.hcup-us.ahrq.gov/toolssoftware/ccs/Multi_Level_CCS_2015.zip
```

Unzip to a folder.

```
unzip Multi_Level_CCS_2015.zip
```

Use Python to convert all apostrophes in `ccs_multi_dx_tool_2015.csv` into double quotes (the file mixed apostrophes/double quotes as field encapsulators):

```python
import pandas as pd
df = pd.read_csv('ccs_multi_dx_tool_2015.csv.gz')
# remove apostrophes from header names and relabel
df.rename(columns={"'ICD-9-CM CODE'": "icd9_code", "'CCS LVL 1'": "ccs_level1", "'CCS LVL 1 LABEL'": "ccs_group1", "'CCS LVL 2'": "ccs_level2", "'CCS LVL 2 LABEL'": "ccs_group2", "'CCS LVL 3'": "ccs_level3", "'CCS LVL 3 LABEL'": "ccs_group3", "'CCS LVL 4'": "ccs_level4", "'CCS LVL 4 LABEL'": "ccs_group4", }, inplace=True)

def remove_surrounding_apostrophes(x):
    if x[0] == "'":
        x = x[1:]
    if x[-1] == "'":
        x = x[:-1]
    return x

for c in df.columns:
    df[c] = df[c].map(remove_surrounding_apostrophes)
    idxRemove = df[c].str.strip() == ''
    if idxRemove.any():
        df.loc[idxRemove, c] = None

# write to file
df.to_csv('ccs_multi_dx.csv.gz', index=False, compression='gzip')
```

(above run with Python 3.7 and pandas 0.23.2).