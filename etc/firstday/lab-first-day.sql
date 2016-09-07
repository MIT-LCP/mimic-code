-- This query pivots lab values taken in the first 24 hours of a patient's stay

-- Have already confirmed that the unit of measurement is always the same: null or the correct unit

drop materialized view IF EXISTS labsfirstday;

create materialized view labsfirstday as
select
  pvt.subject_id, pvt.hadm_id, pvt.icustay_id

  , min(case when label = 'ANION GAP' then valuenum else null end) as ANIONGAP_min
  , max(case when label = 'ANION GAP' then valuenum else null end) as ANIONGAP_max
  , min(case when label = 'ALBUMIN' then valuenum else null end) as ALBUMIN_min
  , max(case when label = 'ALBUMIN' then valuenum else null end) as ALBUMIN_max
  , min(case when label = 'BANDS' then valuenum else null end) as BANDS_min
  , max(case when label = 'BANDS' then valuenum else null end) as BANDS_max
  , min(case when label = 'BICARBONATE' then valuenum else null end) as BICARBONATE_min
  , max(case when label = 'BICARBONATE' then valuenum else null end) as BICARBONATE_max
  , min(case when label = 'BILIRUBIN' then valuenum else null end) as BILIRUBIN_min
  , max(case when label = 'BILIRUBIN' then valuenum else null end) as BILIRUBIN_max
  , min(case when label = 'CREATININE' then valuenum else null end) as CREATININE_min
  , max(case when label = 'CREATININE' then valuenum else null end) as CREATININE_max
  , min(case when label = 'CHLORIDE' then valuenum else null end) as CHLORIDE_min
  , max(case when label = 'CHLORIDE' then valuenum else null end) as CHLORIDE_max
  , min(case when label = 'GLUCOSE' then valuenum else null end) as GLUCOSE_min
  , max(case when label = 'GLUCOSE' then valuenum else null end) as GLUCOSE_max
  , min(case when label = 'HEMATOCRIT' then valuenum else null end) as HEMATOCRIT_min
  , max(case when label = 'HEMATOCRIT' then valuenum else null end) as HEMATOCRIT_max
  , min(case when label = 'HEMOGLOBIN' then valuenum else null end) as HEMOGLOBIN_min
  , max(case when label = 'HEMOGLOBIN' then valuenum else null end) as HEMOGLOBIN_max
  , min(case when label = 'LACTATE' then valuenum else null end) as LACTATE_min
  , max(case when label = 'LACTATE' then valuenum else null end) as LACTATE_max
  , min(case when label = 'PLATELET' then valuenum else null end) as PLATELET_min
  , max(case when label = 'PLATELET' then valuenum else null end) as PLATELET_max
  , min(case when label = 'POTASSIUM' then valuenum else null end) as POTASSIUM_min
  , max(case when label = 'POTASSIUM' then valuenum else null end) as POTASSIUM_max
  , min(case when label = 'PTT' then valuenum else null end) as PTT_min
  , max(case when label = 'PTT' then valuenum else null end) as PTT_max
  , min(case when label = 'INR' then valuenum else null end) as INR_min
  , max(case when label = 'INR' then valuenum else null end) as INR_max
  , min(case when label = 'PT' then valuenum else null end) as PT_min
  , max(case when label = 'PT' then valuenum else null end) as PT_max
  , min(case when label = 'SODIUM' then valuenum else null end) as SODIUM_min
  , max(case when label = 'SODIUM' then valuenum else null end) as SODIUM_max
  , min(case when label = 'BUN' then valuenum else null end) as BUN_min
  , max(case when label = 'BUN' then valuenum else null end) as BUN_max
  , min(case when label = 'WBC' then valuenum else null end) as WBC_min
  , max(case when label = 'WBC' then valuenum else null end) as WBC_max


from
( -- begin query that extracts the data
  select ie.subject_id, ie.hadm_id, ie.icustay_id
  -- here we assign labels to ITEMIDs
  -- this also fuses together multiple ITEMIDs containing the same data
  , case
        when itemid = 50868 then 'ANION GAP'
        when itemid = 50862 then 'ALBUMIN'
        when itemid = 51144 then 'BANDS'
        when itemid = 50882 then 'BICARBONATE'
        when itemid = 50885 then 'BILIRUBIN'
        when itemid = 50912 then 'CREATININE'
        when itemid = 50806 then 'CHLORIDE'
        when itemid = 50902 then 'CHLORIDE'
        when itemid = 50809 then 'GLUCOSE'
        when itemid = 50931 then 'GLUCOSE'
        when itemid = 50810 then 'HEMATOCRIT'
        when itemid = 51221 then 'HEMATOCRIT'
        when itemid = 50811 then 'HEMOGLOBIN'
        when itemid = 51222 then 'HEMOGLOBIN'
        when itemid = 50813 then 'LACTATE'
        when itemid = 51265 then 'PLATELET'
        when itemid = 50822 then 'POTASSIUM'
        when itemid = 50971 then 'POTASSIUM'
        when itemid = 51275 then 'PTT'
        when itemid = 51237 then 'INR'
        when itemid = 51274 then 'PT'
        when itemid = 50824 then 'SODIUM'
        when itemid = 50983 then 'SODIUM'
        when itemid = 51006 then 'BUN'
        when itemid = 51300 then 'WBC'
        when itemid = 51301 then 'WBC'
      else null
    end as label
  , -- add in some sanity checks on the values
  -- the where clause below requires all valuenum to be > 0, so these are only upper limit checks
    case
      when itemid = 50862 and valuenum >    10 then null -- g/dL 'ALBUMIN'
      when itemid = 50868 and valuenum > 10000 then null -- mEq/L 'ANION GAP'
      when itemid = 51144 and valuenum <     0 then null -- immature band forms, %
      when itemid = 51144 and valuenum >   100 then null -- immature band forms, %
      when itemid = 50882 and valuenum > 10000 then null -- mEq/L 'BICARBONATE'
      when itemid = 50885 and valuenum >   150 then null -- mg/dL 'BILIRUBIN'
      when itemid = 50806 and valuenum > 10000 then null -- mEq/L 'CHLORIDE'
      when itemid = 50902 and valuenum > 10000 then null -- mEq/L 'CHLORIDE'
      when itemid = 50912 and valuenum >   150 then null -- mg/dL 'CREATININE'
      when itemid = 50809 and valuenum > 10000 then null -- mg/dL 'GLUCOSE'
      when itemid = 50931 and valuenum > 10000 then null -- mg/dL 'GLUCOSE'
      when itemid = 50810 and valuenum >   100 then null -- % 'HEMATOCRIT'
      when itemid = 51221 and valuenum >   100 then null -- % 'HEMATOCRIT'
      when itemid = 50811 and valuenum >    50 then null -- g/dL 'HEMOGLOBIN'
      when itemid = 51222 and valuenum >    50 then null -- g/dL 'HEMOGLOBIN'
      when itemid = 50813 and valuenum >    50 then null -- mmol/L 'LACTATE'
      when itemid = 51265 and valuenum > 10000 then null -- K/uL 'PLATELET'
      when itemid = 50822 and valuenum >    30 then null -- mEq/L 'POTASSIUM'
      when itemid = 50971 and valuenum >    30 then null -- mEq/L 'POTASSIUM'
      when itemid = 51275 and valuenum >   150 then null -- sec 'PTT'
      when itemid = 51237 and valuenum >    50 then null -- 'INR'
      when itemid = 51274 and valuenum >   150 then null -- sec 'PT'
      when itemid = 50824 and valuenum >   200 then null -- mEq/L == mmol/L 'SODIUM'
      when itemid = 50983 and valuenum >   200 then null -- mEq/L == mmol/L 'SODIUM'
      when itemid = 51006 and valuenum >   300 then null -- 'BUN'
      when itemid = 51300 and valuenum >  1000 then null -- 'WBC'
      when itemid = 51301 and valuenum >  1000 then null -- 'WBC'
    else le.valuenum
    end as valuenum

  from icustays ie

  left join labevents le
    on le.subject_id = ie.subject_id and le.hadm_id = ie.hadm_id
    and le.charttime between (ie.intime - interval '6' hour) and (ie.intime + interval '1' day)
    and le.ITEMID in
    (
      -- comment is: LABEL | CATEGORY | FLUID | NUMBER OF ROWS IN LABEVENTS
      50868, -- ANION GAP | CHEMISTRY | BLOOD | 769895
      50862, -- ALBUMIN | CHEMISTRY | BLOOD | 146697
      51144, -- BANDS - hematology
      50882, -- BICARBONATE | CHEMISTRY | BLOOD | 780733
      50885, -- BILIRUBIN, TOTAL | CHEMISTRY | BLOOD | 238277
      50912, -- CREATININE | CHEMISTRY | BLOOD | 797476
      50902, -- CHLORIDE | CHEMISTRY | BLOOD | 795568
      50806, -- CHLORIDE, WHOLE BLOOD | BLOOD GAS | BLOOD | 48187
      50931, -- GLUCOSE | CHEMISTRY | BLOOD | 748981
      50809, -- GLUCOSE | BLOOD GAS | BLOOD | 196734
      51221, -- HEMATOCRIT | HEMATOLOGY | BLOOD | 881846
      50810, -- HEMATOCRIT, CALCULATED | BLOOD GAS | BLOOD | 89715
      51222, -- HEMOGLOBIN | HEMATOLOGY | BLOOD | 752523
      50811, -- HEMOGLOBIN | BLOOD GAS | BLOOD | 89712
      50813, -- LACTATE | BLOOD GAS | BLOOD | 187124
      51265, -- PLATELET COUNT | HEMATOLOGY | BLOOD | 778444
      50971, -- POTASSIUM | CHEMISTRY | BLOOD | 845825
      50822, -- POTASSIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 192946
      51275, -- PTT | HEMATOLOGY | BLOOD | 474937
      51237, -- INR(PT) | HEMATOLOGY | BLOOD | 471183
      51274, -- PT | HEMATOLOGY | BLOOD | 469090
      50983, -- SODIUM | CHEMISTRY | BLOOD | 808489
      50824, -- SODIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 71503
      51006, -- UREA NITROGEN | CHEMISTRY | BLOOD | 791925
      51301, -- WHITE BLOOD CELLS | HEMATOLOGY | BLOOD | 753301
      51300  -- WBC COUNT | HEMATOLOGY | BLOOD | 2371
    )
    and valuenum is not null and valuenum > 0 -- lab values cannot be 0 and cannot be negative
) pvt
group by pvt.subject_id, pvt.hadm_id, pvt.icustay_id
order by pvt.subject_id, pvt.hadm_id, pvt.icustay_id;

commit;
