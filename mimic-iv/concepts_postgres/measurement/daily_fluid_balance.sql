DROP TABLE IF EXISTS
  mimiciv_derived.daily_fluid_balance
CASCADE;

CREATE TABLE
  mimiciv_derived.daily_fluid_balance AS
SELECT
    i.stay_id,
    i.infusion_date,
    (
    i.total_daily_amount - COALESCE(o.total_output, 0)
  ) as net_balance
FROM
    mimiciv_derived.daily_fluid_in AS i
    LEFT JOIN mimiciv_derived.daily_fluid_out AS o ON i.stay_id = o.stay_id
        AND i.infusion_date = o.day;