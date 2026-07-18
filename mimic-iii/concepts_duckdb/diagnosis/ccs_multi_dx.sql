-- THIS SCRIPT IS HAND-WRITTEN FOR DUCKDB (there is no BigQuery source).
-- Loads the CCS multi-level diagnosis mapping from the CSV distributed
-- alongside this script. On BigQuery the same table is loaded with:
--   bq load mimiciii_derived.ccs_multi_dx diagnosis/ccs_multi_dx.csv.gz diagnosis/ccs_multi_dx.json
-- Run from the concepts_duckdb directory so the relative path resolves.
DROP TABLE IF EXISTS mimiciii_derived.ccs_multi_dx;
CREATE TABLE mimiciii_derived.ccs_multi_dx AS
SELECT *
FROM read_csv(
  'diagnosis/ccs_multi_dx.csv.gz',
  header = true,
  columns = {
    'icd9_code': 'VARCHAR(5)',
    'ccs_level1': 'VARCHAR(10)',
    'ccs_group1': 'VARCHAR(100)',
    'ccs_level2': 'VARCHAR(10)',
    'ccs_group2': 'VARCHAR(100)',
    'ccs_level3': 'VARCHAR(10)',
    'ccs_group3': 'VARCHAR(100)',
    'ccs_level4': 'VARCHAR(10)',
    'ccs_group4': 'VARCHAR(100)'
  }
);
