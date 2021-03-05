DROP TABLE IF EXISTS ccs_dx;
CREATE TABLE ccs_dx
(
  icd9_code CHAR(5) NOT NULL,
  -- we will populate ccs_mid and ccs_name with the most granular ID/name later
  ccs_matched_id VARCHAR(10),
  ccs_matched_name VARCHAR(100),
  ccs_id INTEGER,
  ccs_name VARCHAR(100),
  -- CCS levels and names based on position in hierarchy
  ccs_level1 VARCHAR(10),
  ccs_group1 VARCHAR(100),
  ccs_level2 VARCHAR(10),
  ccs_group2 VARCHAR(100),
  ccs_level3 VARCHAR(10),
  ccs_group3 VARCHAR(100),
  ccs_level4 VARCHAR(10),
  ccs_group4 VARCHAR(100)
);

-- copy all columns *but* ccs_mid and ccs_name
-- we will populate these after the data is loaded in
\COPY ccs_dx (icd9_code, ccs_level1, ccs_group1, ccs_level2, ccs_group2, ccs_level3, ccs_group3, ccs_level4, ccs_group4) FROM PROGRAM 'gzip -dc ccs_multi_dx.csv.gz' CSV HEADER;

-- add in matched ID, name, and ccs_id
--  matched id (ccs_mid): the ccs ID with the hierachy, e.g. 7.1.2.1
--  name (ccs_name): the most granular CCS category the diagnosis is in
--  ID (ccs_id): the CCS identifier for the ICD-9 code (integer)
UPDATE ccs_dx
SET ccs_matched_id=tt.ccs_matched_id, ccs_matched_name=tt.ccs_matched_name,
    ccs_name=tt.ccs_name, ccs_id=CAST(tt.ccs_id AS INTEGER)
FROM (
  SELECT icd9_code
  , COALESCE(ccs_level4, ccs_level3, ccs_level2, ccs_level1) AS ccs_matched_id
  -- remove the trailing ccs_id from name column, i.e. "Burns [240.]" -> "Burns"
  , REGEXP_REPLACE(COALESCE(ccs_group4, ccs_group3, ccs_group2, ccs_group1), '\[[0-9]+\.\]$', '') as ccs_matched_name
  -- ccs_id is sometimes present at a higher level of granularity
  -- e.g. for 7.1.2.1, the CCS name is at level 7.1.2
  -- therefore we pull from the first category to have the CCS ID
  , CASE
    WHEN ccs_group4 ~ '\[([0-9]+)\.\]$' THEN REGEXP_REPLACE(ccs_group4, '\[[0-9]+\.\]$', '')
    WHEN ccs_group3 ~ '\[([0-9]+)\.\]$' THEN REGEXP_REPLACE(ccs_group3, '\[[0-9]+\.\]$', '')
    WHEN ccs_group2 ~ '\[([0-9]+)\.\]$' THEN REGEXP_REPLACE(ccs_group2, '\[[0-9]+\.\]$', '')
    WHEN ccs_group1 ~ '\[([0-9]+)\.\]$' THEN REGEXP_REPLACE(ccs_group1, '\[[0-9]+\.\]$', '')
    ELSE NULL END AS ccs_name
  -- extract the trailing ccs_id from name, i.e. "Burns [240.]" -> "240"
  , COALESCE(
      SUBSTRING(ccs_group4, '\[([0-9]+)\.\]$'),
      SUBSTRING(ccs_group3, '\[([0-9]+)\.\]$'),
      SUBSTRING(ccs_group2, '\[([0-9]+)\.\]$'),
      SUBSTRING(ccs_group1, '\[([0-9]+)\.\]$')
    ) as ccs_id
  FROM ccs_dx
) AS tt
WHERE ccs_dx.icd9_code = tt.icd9_code;