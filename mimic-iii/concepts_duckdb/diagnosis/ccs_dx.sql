-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.ccs_dx; CREATE TABLE mimiciii_derived.ccs_dx AS
SELECT
  icd9_code,
  COALESCE(ccs_level4, ccs_level3, ccs_level2, ccs_level1) AS ccs_matched_id,
  REGEXP_REPLACE(COALESCE(ccs_group4, ccs_group3, ccs_group2, ccs_group1), '\[[0-9]+\.\]$', '', 'g') AS ccs_matched_name,
  CASE
    WHEN REGEXP_MATCHES(ccs_group4, '\[([0-9]+)\.\]$')
    THEN REGEXP_REPLACE(ccs_group4, '\[[0-9]+\.\]$', '', 'g')
    WHEN REGEXP_MATCHES(ccs_group3, '\[([0-9]+)\.\]$')
    THEN REGEXP_REPLACE(ccs_group3, '\[[0-9]+\.\]$', '', 'g')
    WHEN REGEXP_MATCHES(ccs_group2, '\[([0-9]+)\.\]$')
    THEN REGEXP_REPLACE(ccs_group2, '\[[0-9]+\.\]$', '', 'g')
    WHEN REGEXP_MATCHES(ccs_group1, '\[([0-9]+)\.\]$')
    THEN REGEXP_REPLACE(ccs_group1, '\[[0-9]+\.\]$', '', 'g')
    ELSE NULL
  END AS ccs_name,
  COALESCE(
    NULLIF(REGEXP_EXTRACT(ccs_group4, '\[([0-9]+)\.\]$', 1), ''),
    NULLIF(REGEXP_EXTRACT(ccs_group3, '\[([0-9]+)\.\]$', 1), ''),
    NULLIF(REGEXP_EXTRACT(ccs_group2, '\[([0-9]+)\.\]$', 1), ''),
    NULLIF(REGEXP_EXTRACT(ccs_group1, '\[([0-9]+)\.\]$', 1), '')
  ) AS ccs_id,
  ccs_level1,
  ccs_group1,
  ccs_level2,
  ccs_group2,
  ccs_level3,
  ccs_group3,
  ccs_level4,
  ccs_group4
FROM mimiciii_derived.ccs_multi_dx
ORDER BY
  icd9_code NULLS FIRST