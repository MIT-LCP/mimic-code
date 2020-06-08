-- add in matched ID, name, and ccs_id
--  matched id (ccs_mid): the ccs ID with the hierachy, e.g. 7.1.2.1
--  name (ccs_name): the most granular CCS category the diagnosis is in
--  ID (ccs_id): the CCS identifier for the ICD-9 code (integer)
SELECT
    icd9_code
  , COALESCE(ccs_level4, ccs_level3, ccs_level2, ccs_level1) AS ccs_matched_id
  -- remove the trailing ccs_id from name column, i.e. "Burns [240.]" -> "Burns"
  , REGEXP_REPLACE(COALESCE(ccs_group4, ccs_group3, ccs_group2, ccs_group1), '\\[[0-9]+\\.\\]$', '') as ccs_matched_name
  -- ccs_id is sometimes present at a higher level of granularity
  -- e.g. for 7.1.2.1, the CCS name is at level 7.1.2
  -- therefore we pull from the first category to have the CCS ID
  , CASE
    WHEN REGEXP_CONTAINS(ccs_group4, '\\[([0-9]+)\\.\\]$') THEN REGEXP_REPLACE(ccs_group4, '\\[[0-9]+\\.\\]$', '')
    WHEN REGEXP_CONTAINS(ccs_group3, '\\[([0-9]+)\\.\\]$') THEN REGEXP_REPLACE(ccs_group3, '\\[[0-9]+\\.\\]$', '')
    WHEN REGEXP_CONTAINS(ccs_group2, '\\[([0-9]+)\\.\\]$') THEN REGEXP_REPLACE(ccs_group2, '\\[[0-9]+\\.\\]$', '')
    WHEN REGEXP_CONTAINS(ccs_group1, '\\[([0-9]+)\\.\\]$') THEN REGEXP_REPLACE(ccs_group1, '\\[[0-9]+\\.\\]$', '')
    ELSE NULL END AS ccs_name
  -- extract the trailing ccs_id from name, i.e. "Burns [240.]" -> "240"
  , COALESCE(
      REGEXP_EXTRACT(ccs_group4, '\\[([0-9]+)\\.\\]$'),
      REGEXP_EXTRACT(ccs_group3, '\\[([0-9]+)\\.\\]$'),
      REGEXP_EXTRACT(ccs_group2, '\\[([0-9]+)\\.\\]$'),
      REGEXP_EXTRACT(ccs_group1, '\\[([0-9]+)\\.\\]$')
    ) as ccs_id
  , ccs_level1
  , ccs_group1
  , ccs_level2
  , ccs_group2
  , ccs_level3
  , ccs_group3
  , ccs_level4
  , ccs_group4
FROM `physionet-data.mimiciii_derived.ccs_multi_dx`
ORDER BY icd9_code