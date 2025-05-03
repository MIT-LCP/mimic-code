drop table if exists rrt_first_day; create table rrt_first_day as 
-- determines if patients received any dialysis during their stay

-- Some example aggregate queries which summarize the data here.
-- This query estimates 6.7% of ICU patients received RRT.
    -- select count(rrt.icustay_id) as numobs
    -- , sum(rrt) as numrrt
    -- , sum(case when rrt=1 then 1 else 0 end)*100.0 / count(rrt.icustay_id)
    -- as percent_rrt
    -- from rrt
    -- inner join icustays ie on rrt.icustay_id = ie.icustay_id
    -- inner join patients p
    -- on rrt.subject_id = p.subject_id
    -- and p.dob < ie.intime - interval '1' year
    -- inner join admissions adm
    -- on rrt.hadm_id = adm.hadm_id;

-- This query estimates that 4.6% of first ICU stays received RRT.
    -- select
    --   count(rrt.icustay_id) as numobs
    --   , sum(rrt) as numrrt
    --   , sum(case when rrt=1 then 1 else 0 end)*100.0 / count(rrt.icustay_id)
    -- as percent_rrt
    -- from
    -- (
    -- select ie.icustay_id, rrt.rrt
    --   , row_number() over (partition by ie.subject_id order by ie.intime) rn
    -- from rrt
    -- inner join icustays ie
    --   on rrt.icustay_id = ie.icustay_id
    -- inner join patients p
    --   on rrt.subject_id = p.subject_id
    -- and p.dob < ie.intime - interval '1' year
    -- inner join admissions adm
    --   on rrt.hadm_id = adm.hadm_id
    -- ) rrt
    -- where rn = 1;

with cv as
(
  select ie.icustay_id
    , max(
        case
          when ce.itemid in (152,148,149,146,147,151,150) and value is not null then 1
          when ce.itemid in (229,235,241,247,253,259,265,271) and value = 'Dialysis Line' then 1
          when ce.itemid = 582 and value in ('CAVH Start','CAVH D/C','CVVHD Start','CVVHD D/C','Hemodialysis st','Hemodialysis end') then 1
        else 0 end
        ) as rrt
  from icustays ie
  inner join chartevents ce
    on ie.icustay_id = ce.icustay_id
    and ce.itemid in
    (
       152 -- "Dialysis Type";61449
      ,148 -- "Dialysis Access Site";60335
      ,149 -- "Dialysis Access Type";60030
      ,146 -- "Dialysate Flow ml/hr";57445
      ,147 -- "Dialysate Infusing";56605
      ,151 -- "Dialysis Site Appear";37345
      ,150 -- "Dialysis Machine";27472
      ,229 -- INV Line#1 [Type]
      ,235 -- INV Line#2 [Type]
      ,241 -- INV Line#3 [Type]
      ,247 -- INV Line#4 [Type]
      ,253 -- INV Line#5 [Type]
      ,259 -- INV Line#6 [Type]
      ,265 -- INV Line#7 [Type]
      ,271 -- INV Line#8 [Type]
      ,582 -- Procedures
    )
    and ce.value is not null
    and ce.charttime between ie.intime and (ie.intime + interval '1 day')
  where ie.dbsource = 'carevue'
  group by ie.icustay_id
)

select ie.subject_id, ie.hadm_id, ie.icustay_id
  , case
      when cv.rrt = 1 then 1
      else 0
    end as rrt
from icustays ie
left join cv
  on ie.icustay_id = cv.icustay_id
order by ie.icustay_id;