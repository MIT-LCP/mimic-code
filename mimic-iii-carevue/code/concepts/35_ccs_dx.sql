drop table if exists ccs_dx;
create table ccs_dx
(
  icd9_code char(5) not null,
  -- we will populate ccs_mid and ccs_name with the most granular id/name later
  ccs_matched_id varchar(10),
  ccs_matched_name varchar(100),
  ccs_id integer,
  ccs_name varchar(100),
  -- ccs levels and names based on position in hierarchy
  ccs_level1 varchar(10),
  ccs_group1 varchar(100),
  ccs_level2 varchar(10),
  ccs_group2 varchar(100),
  ccs_level3 varchar(10),
  ccs_group3 varchar(100),
  ccs_level4 varchar(10),
  ccs_group4 varchar(100)
);

-- copy all columns *but* ccs_mid and ccs_name
-- we will populate these after the data is loaded in
\copy ccs_dx (icd9_code, ccs_level1, ccs_group1, ccs_level2, ccs_group2, ccs_level3, ccs_group3, ccs_level4, ccs_group4) from program 'gzip -dc ./code/concepts/dx_data/ccs_multi_dx.csv.gz' csv header;

-- add in matched ID, name, and ccs_id
--  matched id (ccs_mid): the ccs ID with the hierachy, e.g. 7.1.2.1
--  name (ccs_name): the most granular CCS category the diagnosis is in
--  ID (ccs_id): the CCS identifier for the ICD-9 code (integer)
update ccs_dx
set ccs_matched_id=tt.ccs_matched_id, ccs_matched_name=tt.ccs_matched_name,
    ccs_name=tt.ccs_name, ccs_id=cast(tt.ccs_id as integer)
from (
  select icd9_code
  , coalesce(ccs_level4, ccs_level3, ccs_level2, ccs_level1) as ccs_matched_id
  -- remove the trailing ccs_id from name column, i.e. "Burns [240.]" -> "Burns"
  , regexp_replace(coalesce(ccs_group4, ccs_group3, ccs_group2, ccs_group1), '\[[0-9]+\.\]$', '') as ccs_matched_name
  -- ccs_id is sometimes present at a higher level of granularity
  -- e.g. for 7.1.2.1, the CCS name is at level 7.1.2
  -- therefore we pull from the first category to have the CCS ID
  , case
    when ccs_group4 ~ '\[([0-9]+)\.\]$' then regexp_replace(ccs_group4, '\[[0-9]+\.\]$', '')
    when ccs_group3 ~ '\[([0-9]+)\.\]$' then regexp_replace(ccs_group3, '\[[0-9]+\.\]$', '')
    when ccs_group2 ~ '\[([0-9]+)\.\]$' then regexp_replace(ccs_group2, '\[[0-9]+\.\]$', '')
    when ccs_group1 ~ '\[([0-9]+)\.\]$' then regexp_replace(ccs_group1, '\[[0-9]+\.\]$', '')
    else null end as ccs_name
  -- extract the trailing ccs_id from name, i.e. "burns [240.]" -> "240"
  , coalesce(
      substring(ccs_group4, '\[([0-9]+)\.\]$'),
      substring(ccs_group3, '\[([0-9]+)\.\]$'),
      substring(ccs_group2, '\[([0-9]+)\.\]$'),
      substring(ccs_group1, '\[([0-9]+)\.\]$')
    ) as ccs_id
  from ccs_dx
) as tt
where ccs_dx.icd9_code = tt.icd9_code;