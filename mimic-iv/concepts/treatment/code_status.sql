-- This query extracts:
--    i) a patient's first code status
--    ii) a patient's last code status
--    iii) the time of the first entry of DNR or CMO

with t1 as (
  /*
There are five distinct values for the code status order in the dataset:
1 DNR / DNI
2	DNI (do not intubate)
3	Comfort measures only
4	Full code
5	DNR (do not resuscitate)
 */

    select
        stay_id,
        charttime,
        value,
        -- use row number to identify first and last code status
        ROW_NUMBER() over (partition by stay_id order by charttime) as rnfirst,
        ROW_NUMBER() over (
            partition by stay_id order by charttime desc
        ) as rnlast,
        -- coalesce the values
        case
            when value in ('Full code') then 1
            else 0 end as fullcode,
        case
            when value in ('Comfort measures only') then 1
            else 0 end as cmo,
        case
            when value in ('DNI (do not intubate)', 'DNR / DNI') then 1
            else 0 end as dni,
        case
            when value in ('DNR (do not resuscitate)', 'DNR / DNI') then 1
            else 0 end as dnr
    from `physionet-data.mimic_icu.chartevents`
    where itemid in (223758)
)

select
    ie.subject_id,
    ie.hadm_id,
    ie.stay_id,
    -- first recorded code status
    MAX(
        case when rnfirst = 1 then t1.fullcode end
    ) as fullcode_first,
    MAX(case when rnfirst = 1 then t1.cmo end) as cmo_first,
    MAX(case when rnfirst = 1 then t1.dnr end) as dnr_first,
    MAX(case when rnfirst = 1 then t1.dni end) as dni_first,

    -- last recorded code status
    MAX(
        case when rnlast = 1 then t1.fullcode end
    ) as fullcode_last,
    MAX(case when rnlast = 1 then t1.cmo end) as cmo_last,
    MAX(case when rnlast = 1 then t1.dnr end) as dnr_last,
    MAX(case when rnlast = 1 then t1.dni end) as dni_last,

    -- were they *at any time* given a certain code status
    MAX(t1.fullcode) as fullcode,
    MAX(t1.cmo) as cmo,
    MAX(t1.dnr) as dnr,
    MAX(t1.dni) as dni,

    -- time until their first DNR
    MIN(case when t1.dnr = 1 then t1.charttime end)
    as dnr_first_charttime,
    MIN(case when t1.dni = 1 then t1.charttime end)
    as dni_first_charttime,

    -- first code status of CMO
    MIN(case when t1.cmo = 1 then t1.charttime end)
    as timecmo_chart

from `physionet-data.mimic_icu.icustays` as ie
left join t1
          on ie.stay_id = t1.stay_id
group by ie.subject_id, ie.hadm_id, ie.stay_id, ie.intime;
