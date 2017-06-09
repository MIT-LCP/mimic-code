The Clinical Classification Software (CCS) categorizes ICD-9 coded diagnoses into clinically meaningful groups. The categorization was developed by the Agency for Healthcare Research and Quality (AHRQ). More detail can be found on the AHRQ website: https://www.hcup-us.ahrq.gov/tools_software.jsp

This folder contains:

* `ccs_diagnosis_table.sql` - Creates two tables: `ccs_single_level_dx` and `ccs_multi_level_dx`. These two tables are loaded from `ccs_single_level_dx.csv.gz` and `ccs_multi_level_dx.csv.gz`. Note that the script assumes you are using PostgreSQL v9.4 or later, and you must execute the script from this directory.
