-- Functions TODO:
--  FROM table CROSS JOIN UNNEST(table.column) AS col -> ????  (see icustay-hours)
--  ???(column) -> PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY column)    (not sure how to do median in BQ)

CREATE OR REPLACE FUNCTION REGEXP_EXTRACT(str TEXT, pattern TEXT) RETURNS TEXT AS $$
BEGIN
RETURN substring(str from pattern);
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION REGEXP_CONTAINS(str TEXT, pattern TEXT) RETURNS BOOL AS $$
BEGIN
RETURN str ~ pattern;
END; $$
LANGUAGE PLPGSQL;

-- alias generate_series with generate_array
CREATE OR REPLACE FUNCTION GENERATE_ARRAY(i INTEGER, j INTEGER)
RETURNS setof INTEGER language sql as $$
    SELECT GENERATE_SERIES(i, j)
$$;

-- datetime functions
CREATE OR REPLACE FUNCTION DATETIME(dt DATE) RETURNS TIMESTAMP(3) AS $$
BEGIN
RETURN CAST(dt AS TIMESTAMP(3));
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION DATETIME(year INTEGER, month INTEGER, day INTEGER, hour INTEGER, minute INTEGER, second INTEGER) RETURNS TIMESTAMP(3) AS $$
BEGIN
RETURN TO_TIMESTAMP(
    TO_CHAR(year, '0000') || TO_CHAR(month, '00') || TO_CHAR(day, '00') || TO_CHAR(hour, '00') || TO_CHAR(minute, '00') || TO_CHAR(second, '00'),
    'yyyymmddHH24MISS'
);
END; $$
LANGUAGE PLPGSQL;

-- note: in bigquery, `INTERVAL 1 YEAR` is a valid interval
-- but in postgres, it must be `INTERVAL '1' YEAR`

--  DATETIME_ADD(datetime, INTERVAL 'n' DATEPART) -> datetime + INTERVAL 'n' DATEPART
CREATE OR REPLACE FUNCTION DATETIME_ADD(datetime_val TIMESTAMP(3), intvl INTERVAL) RETURNS TIMESTAMP(3) AS $$
BEGIN
RETURN datetime_val + intvl;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION DATE_ADD(dt DATE, intvl INTERVAL) RETURNS TIMESTAMP(3) AS $$
BEGIN
RETURN CAST(dt AS TIMESTAMP(3)) + intvl;
END; $$
LANGUAGE PLPGSQL;

--  DATETIME_SUB(datetime, INTERVAL 'n' DATEPART) -> datetime - INTERVAL 'n' DATEPART
CREATE OR REPLACE FUNCTION DATETIME_SUB(datetime_val TIMESTAMP(3), intvl INTERVAL) RETURNS TIMESTAMP(3) AS $$
BEGIN
RETURN datetime_val - intvl;
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION DATE_SUB(dt DATE, intvl INTERVAL) RETURNS TIMESTAMP(3) AS $$
BEGIN
RETURN CAST(dt AS TIMESTAMP(3)) - intvl;
END; $$
LANGUAGE PLPGSQL;

-- TODO:
--   DATETIME_TRUNC(datetime, PART) -> DATE_TRUNC('datepart', datetime)

-- below requires a regex to convert datepart from primitive to a string
-- i.e. encapsulate it in single quotes
CREATE OR REPLACE FUNCTION DATETIME_DIFF(endtime TIMESTAMP(3), starttime TIMESTAMP(3), datepart TEXT) RETURNS NUMERIC AS $$
BEGIN
RETURN 
    EXTRACT(EPOCH FROM endtime - starttime) /
    CASE
        WHEN datepart = 'SECOND' THEN 1.0
        WHEN datepart = 'MINUTE' THEN 60.0
        WHEN datepart = 'HOUR' THEN 3600.0
        WHEN datepart = 'DAY' THEN 24*3600.0
        WHEN datepart = 'YEAR' THEN 365.242*24*3600.0
    ELSE NULL END;
END; $$
LANGUAGE PLPGSQL;

-- BigQuery has a custom data type, PART
-- It's difficult to replicate this in postgresql, which recognizes the PART as a column name,
-- unless it is within an EXTRACT() function.

CREATE OR REPLACE FUNCTION BIGQUERY_FORMAT_TO_PSQL(format_str VARCHAR(255)) RETURNS TEXT AS $$
BEGIN
RETURN 
    -- use replace to convert BigQuery string format to postgres string format
    -- only handles a few cases since we don't extensively use this function
    REPLACE(
    REPLACE(
    REPLACE(
    REPLACE(
    REPLACE(
    REPLACE(
        format_str
        , '%S', 'SS'
    )
        , '%M', 'MI'
    )
        , '%H', 'HH24'
    )
        , '%d', 'dd'
    )
        , '%m', 'mm'
    )
        , '%Y', 'yyyy'
    )
;
END; $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION FORMAT_DATE(format_str VARCHAR(255), datetime_val TIMESTAMP(3)) RETURNS TEXT AS $$
BEGIN
RETURN TO_CHAR(
    datetime_val,
    -- use replace to convert BigQuery string format to postgres string format
    -- only handles a few cases since we don't extensively use this function
    BIGQUERY_FORMAT_TO_PSQL(format_str)
);
END; $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION PARSE_DATE(format_str VARCHAR(255), string_val VARCHAR(255)) RETURNS DATE AS $$
BEGIN
RETURN TO_DATE(
    string_val,
    -- use replace to convert BigQuery string format to postgres string format
    -- only handles a few cases since we don't extensively use this function
    BIGQUERY_FORMAT_TO_PSQL(format_str)
);
END; $$
LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION FORMAT_DATETIME(format_str VARCHAR(255), datetime_val TIMESTAMP(3)) RETURNS TEXT AS $$
BEGIN
RETURN TO_CHAR(
    datetime_val,
    -- use replace to convert BigQuery string format to postgres string format
    -- only handles a few cases since we don't extensively use this function
    BIGQUERY_FORMAT_TO_PSQL(format_str)
);
END; $$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION PARSE_DATETIME(format_str VARCHAR(255), string_val VARCHAR(255)) RETURNS TIMESTAMP(3) AS $$
BEGIN
RETURN TO_TIMESTAMP(
    string_val,
    -- use replace to convert BigQuery string format to postgres string format
    -- only handles a few cases since we don't extensively use this function
    BIGQUERY_FORMAT_TO_PSQL(format_str)
);
END; $$
LANGUAGE PLPGSQL;


