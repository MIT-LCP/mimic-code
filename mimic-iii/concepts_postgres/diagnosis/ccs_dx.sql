-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.ccs_dx; CREATE TABLE mimiciii_derived.ccs_dx AS
/* add in matched ID, name, and ccs_id */ /*  matched id (ccs_mid): the ccs ID with the hierachy, e.g. 7.1.2.1 */ /*  name (ccs_name): the most granular CCS category the diagnosis is in */ /*  ID (ccs_id): the CCS identifier for the ICD-9 code (integer) */
SELECT
  icd9_code,
  COALESCE(ccs_level4, ccs_level3, ccs_level2, ccs_level1) AS ccs_matched_id, /* remove the trailing ccs_id from name column, i.e. "Burns [240.]" -> "Burns" */
  REGEXP_REPLACE(COALESCE(ccs_group4, ccs_group3, ccs_group2, ccs_group1), '\[[0-9]+\.\]$', '', 'g') AS ccs_matched_name, /* ccs_id is sometimes present at a higher level of granularity */ /* e.g. for 7.1.2.1, the CCS name is at level 7.1.2 */ /* therefore we pull from the first category to have the CCS ID */
  CASE
    WHEN ccs_group4 ~ '\[([0-9]+)\.\]$'
    THEN REGEXP_REPLACE(ccs_group4, '\[[0-9]+\.\]$', '', 'g')
    WHEN ccs_group3 ~ '\[([0-9]+)\.\]$'
    THEN REGEXP_REPLACE(ccs_group3, '\[[0-9]+\.\]$', '', 'g')
    WHEN ccs_group2 ~ '\[([0-9]+)\.\]$'
    THEN REGEXP_REPLACE(ccs_group2, '\[[0-9]+\.\]$', '', 'g')
    WHEN ccs_group1 ~ '\[([0-9]+)\.\]$'
    THEN REGEXP_REPLACE(ccs_group1, '\[[0-9]+\.\]$', '', 'g')
    ELSE NULL
  END AS ccs_name, /* extract the trailing ccs_id from name, i.e. "Burns [240.]" -> "240" */
  COALESCE(
    SUBSTRING(ccs_group4 FROM '\[([0-9]+)\.\]$'),
    SUBSTRING(ccs_group3 FROM '\[([0-9]+)\.\]$'),
    SUBSTRING(ccs_group2 FROM '\[([0-9]+)\.\]$'),
    SUBSTRING(ccs_group1 FROM '\[([0-9]+)\.\]$')
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