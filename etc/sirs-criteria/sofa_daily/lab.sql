-- ------------------------------------------------------------------
-- Original Source: https://github.com/MIT-LCP/mimic-code/blob/3f004bc0d7f3e7c858228f7a06c37736e954580f/etc/firstday/labs-first-day.sql
-- modified to calculate some data without the limitation of the first day 
-- and to get the data of each calendar day
-- ------------------------------------------------------------------

create table a_labs as
select
  pvt.subject_id, pvt.hadm_id, pvt.icustay_id
  , max(case when label = 'BILIRUBIN' then valuenum else null end) as BILIRUBIN_max
  , max(case when label = 'CREATININE' then valuenum else null end) as CREATININE_max
  , min(case when label = 'PLATELET' then valuenum else null end) as PLATELET_min
  , dailyInterval

from
( -- begin query that extracts the data
  select ie.subject_id, ie.hadm_id, ie.icustay_id
  -- here we assign labels to ITEMIDs
  -- this also fuses together multiple ITEMIDs containing the same data
  , case

        when itemid = 50885 then 'BILIRUBIN'
        when itemid = 50912 then 'CREATININE'
        when itemid = 51265 then 'PLATELET'

      else null
    end as label
  , 
  -- add in some sanity checks on the values
  -- the where clause below requires all valuenum to be > 0, so these are only upper limit checks
    case

      when itemid = 50885 and valuenum >   150 then null -- mg/dL 'BILIRUBIN'
      when itemid = 50912 and valuenum >   150 then null -- mg/dL 'CREATININE'
      when itemid = 51265 and valuenum > 10000 then null -- K/uL 'PLATELET'
    else le.valuenum
    end as valuenum
    ,datediff('day', ie.intime::date, charttime::date) AS dailyInterval

  from icustays ie

  left join labevents le
    on le.subject_id = ie.subject_id and le.hadm_id = ie.hadm_id
    and le.charttime between (ie.intime - interval '6' hour) and ie.outtime
    and le.ITEMID in
    (
      -- comment is: LABEL | CATEGORY | FLUID | NUMBER OF ROWS IN LABEVENTS
      50885, -- BILIRUBIN, TOTAL | CHEMISTRY | BLOOD | 238277
      50912, -- CREATININE | CHEMISTRY | BLOOD | 797476
      51265  -- PLATELET COUNT | HEMATOLOGY | BLOOD | 778444

    )
    and valuenum is not null and valuenum > 0 -- lab values cannot be 0 and cannot be negative
) pvt
where dailyInterval < 10
group by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, dailyInterval
order by pvt.subject_id, pvt.hadm_id, pvt.icustay_id, dailyInterval;
;