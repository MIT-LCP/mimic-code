
-- ------------------------------------------------------------------
-- Create a table that shows the sequence of days spent in the ICU --
-- and assign a timestamp to the start and end of each day         -- 
-- ------------------------------------------------------------------

-- ----------
-- Columns:
-- ----------
-- icustay_id
-- intime
-- outime
-- icudayseq_asc:  Ascending sequence of days since arrival in the ICU
-- 				   0 = day of arrival in the ICU
--                 1 = first day after arrival
--                 2 = second day after arrival etc
-- icudayseq_desc: Descending sequence of days since arrival in the ICU
-- 				   0 = day of arrival in the ICU
--                 1 = first day after arrival
--                 2 = second day after arrival etc
-- startday: if day of arrival then intime, else midnight at start of day
-- endday: if day of discharge then outtime, else midnight at end of day
-- ----------

DROP MATERIALIZED VIEW icustay_days;
CREATE MATERIALIZED VIEW icustay_days AS
WITH dayseq AS (
	SELECT icustay_id, intime, outtime,
       GENERATE_SERIES(0,CEIL(los)::INT-1,1) AS icudayseq_asc, 
       GENERATE_SERIES(CEIL(los)::INT-1,0,-1) AS icudayseq_desc
	FROM icustays)
SELECT icustay_id, intime, outtime, 
    icudayseq_asc, icudayseq_desc, 
    CASE WHEN icudayseq_asc = 0 THEN intime
        ELSE date_trunc('day', intime) + (INTERVAL '1 day' * icudayseq_asc) 
        END AS startday,
    CASE WHEN icudayseq_desc = 0 THEN OUTTIME
        ELSE date_trunc('day', intime) + INTERVAL '1 day' + (INTERVAL '1 day' * icudayseq_asc) END AS endday
FROM dayseq;
