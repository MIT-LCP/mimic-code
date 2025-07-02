drop table if exists height_first_day; create table height_first_day as 
-- This query extracts heights for adult ICU patients.
-- It uses all information from the patient's first ICU day.
-- This is done for consistency with other queries - it's not necessarily needed.
-- Height is unlikely to change throughout a patient's stay.
-- staging table to ensure all heights are in centimeters
with ce0 as
(
    select
      c.icustay_id
      , case
        -- convert inches to centimetres
          when itemid in (920, 1394, 4187, 3486)
              then valuenum * 2.54
            else valuenum
        end as height
    from chartevents c
    inner join icustays ie
        on c.icustay_id = ie.icustay_id
        and c.charttime <= (ie.intime + interval '1 day')
        and c.charttime > (ie.intime - interval '1 day') -- some fuzziness for admit time
    where c.valuenum is not null
    and c.itemid in (920, 1394, 4187, 3486, 3485, 4188) -- height
    and c.valuenum != 0
    -- exclude rows marked as error
    and (c.error is null or c.error = 0)
)
, ce as
(
    select
        icustay_id
        -- extract the median height from the chart to add robustness against outliers
        , avg(height) as height_chart
    from ce0
    where height > 100
    group by icustay_id
)

select
    ie.icustay_id
    , ce.height_chart as height
    -- components
    , ce.height_chart
from icustays ie
-- filter to only adults
inner join patients pat
    on ie.subject_id = pat.subject_id
    and ie.intime > (pat.dob + interval '1 year')
left join ce
    on ie.icustay_id = ce.icustay_id;