
-- ----------------------------------------------------------
-- Create a table that counts each day spent in the ICU    --
-- and assign a timestamp to the start and end of each day --
-- ----------------------------------------------------------

-- ----------
-- Columns:
-- ----------
-- icustay_id
-- intime
-- outime
-- icudayseq_asc:  Counting days since arrival in the ICU
-- 				         0 = day of arrival in the ICU
--                 1 = day 1 after arrival
--                 2 = day 2 after arrival etc
-- icudayseq_desc: Counting down to the day of discharge from the ICU
--                 2 = day 2 before discharge etc
--                 1 = day 1 before discharge
-- 				         0 = day of discharge from the ICU
-- startday: if day of arrival then intime, else midnight at start of day
-- endday: if day of discharge then outtime, else midnight at end of day
-- ----------

DROP MATERIALIZED VIEW icustay_days;
CREATE VIEW icustay_days AS
WITH dayseq AS (
	SELECT icustay_id, intime, outtime,
       GENERATE_SERIES(0,CEIL(los)::INT-1,1) AS icudayseq_asc,
       GENERATE_SERIES(CEIL(los)::INT-1,0,-1) AS icudayseq_desc
	FROM `physionet-data.mimiciii_clinical.icustays`)
SELECT icustay_id, intime, outtime,
    icudayseq_asc, icudayseq_desc,
    CASE WHEN icudayseq_asc = 0 THEN intime
        ELSE DATETIME_ADD(date_trunc('day', intime), INTERVAL icudayseq_asc DAY)
        END AS startday,
    CASE WHEN icudayseq_desc = 0 THEN OUTTIME
        ELSE DATETIME_ADD(date_trunc('day', intime), INTERVAL icudayseq_asc+1 DAY)
				END AS endday
FROM dayseq;
