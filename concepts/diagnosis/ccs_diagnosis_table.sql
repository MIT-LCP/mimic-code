DROP TABLE IF EXISTS ccs_single_level_dx;
CREATE TABLE ccs_single_level_dx
(
  ccs_id INT NOT NULL,
  ccs_name VARCHAR(150) NOT NULL,
  icd9_code CHAR(5) NOT NULL
);

\copy ccs_single_level_dx from program 'gzip -dc ccs_single_level.csv.gz' CSV HEADER;

DROP TABLE IF EXISTS ccs_multi_level_dx;
CREATE TABLE ccs_multi_level_dx
(
  ccs_mid VARCHAR(10) NOT NULL,
  ccs_name VARCHAR(100) NOT NULL,
  ccs_group1 VARCHAR(100),
  ccs_group2 VARCHAR(100),
  ccs_group3 VARCHAR(100),
  icd9_code CHAR(5) NOT NULL
);

\copy ccs_multi_level_dx from program 'gzip -dc ccs_multi_level.csv.gz' CSV HEADER;
