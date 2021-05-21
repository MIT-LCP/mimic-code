The *fluid_map* table can be created and loaded into PostgreSQL as follows:

```sql
DROP TABLE IF EXISTS fluid_map;
CREATE TABLE fluid_map
(
  itemid INT NOT NULL,
  label VARCHAR(200),
  abbreviation VARCHAR(100),
  dbsource VARCHAR(20),
  linksto VARCHAR(50),
  category VARCHAR(100),
  unitname VARCHAR(100),
  param_type VARCHAR(30),
  grp VARCHAR(255),
  preadmission VARCHAR(255),
  comment VARCHAR(255)
);

\COPY fluid_map FROM 'fluid_map.csv' CSV HEADER;
```