DROP TABLE IF EXISTS mimiciv_derived.daily_fluid_in
CASCADE;
CREATE TABLE mimiciv_derived.daily_fluid_in AS
WITH RECURSIVE infusion_days AS
(
  SELECT stay_id,
  CAST(starttime AS DATE) AS infusion_date,
  CASE 
           WHEN CAST(starttime AS DATE) = CAST(endtime AS DATE) THEN amount
           ELSE amount / EXTRACT(EPOCH FROM (endtime - starttime)) / 3600 * (24 - EXTRACT(HOUR FROM starttime))
         END AS daily_amount,
  endtime
FROM mimiciv_icu.inputevents
WHERE amountuom = 'ml'
)
SELECT stay_id, infusion_date, SUM(daily_amount) AS total_daily_amount
FROM infusion_days
GROUP BY stay_id, infusion_date
ORDER BY stay_id, infusion_date;