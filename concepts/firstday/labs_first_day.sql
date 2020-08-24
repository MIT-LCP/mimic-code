-- This query pivots lab values taken in the first 24 hours of a patient's stay
-- Have already confirmed that the unit of measurement is always the same: NULL or the correct unit
WITH pvt AS ( -- begin query that extracts the data
  SELECT
  ie.subject_id
  , ie.hadm_id
  , ie.stay_id
  -- here we assign labels to ITEMIDs
  -- this also fuses together multiple ITEMIDs containing the same data
  , CASE
        WHEN itemid = 50868 THEN 'ANION GAP'
        WHEN itemid = 50862 THEN 'ALBUMIN'
        WHEN itemid = 51144 THEN 'BANDS'
        WHEN itemid = 50882 THEN 'BICARBONATE'
        WHEN itemid = 50885 THEN 'BILIRUBIN'
        WHEN itemid = 50912 THEN 'CREATININE'
        WHEN itemid = 50806 THEN 'CHLORIDE'
        WHEN itemid = 50902 THEN 'CHLORIDE'
        WHEN itemid = 50809 THEN 'GLUCOSE'
        WHEN itemid = 50931 THEN 'GLUCOSE'
        WHEN itemid = 50810 THEN 'HEMATOCRIT'
        WHEN itemid = 51221 THEN 'HEMATOCRIT'
        WHEN itemid = 50811 THEN 'HEMOGLOBIN'
        WHEN itemid = 51222 THEN 'HEMOGLOBIN'
        WHEN itemid = 50813 THEN 'LACTATE'
        WHEN itemid = 51265 THEN 'PLATELET'
        WHEN itemid = 50822 THEN 'POTASSIUM'
        WHEN itemid = 50971 THEN 'POTASSIUM'
        WHEN itemid = 51275 THEN 'PTT'
        WHEN itemid = 51237 THEN 'INR'
        WHEN itemid = 51274 THEN 'PT'
        WHEN itemid = 50824 THEN 'SODIUM'
        WHEN itemid = 50983 THEN 'SODIUM'
        WHEN itemid = 51006 THEN 'BUN'
        WHEN itemid = 51300 THEN 'WBC'
        WHEN itemid = 51301 THEN 'WBC'
      ELSE NULL
    END AS label
  , -- add in some sanity checks on the values
  -- the where clause below requires all valuenum to be > 0, so these are only upper limit checks
    CASE
        WHEN itemid = 50862 AND valuenum >    10 THEN NULL -- g/dL 'ALBUMIN'
        WHEN itemid = 50868 AND valuenum > 10000 THEN NULL -- mEq/L 'ANION GAP'
        WHEN itemid = 51144 AND valuenum <     0 THEN NULL -- immature band forms, %
        WHEN itemid = 51144 AND valuenum >   100 THEN NULL -- immature band forms, %
        WHEN itemid = 50882 AND valuenum > 10000 THEN NULL -- mEq/L 'BICARBONATE'
        WHEN itemid = 50885 AND valuenum >   150 THEN NULL -- mg/dL 'BILIRUBIN'
        WHEN itemid = 50806 AND valuenum > 10000 THEN NULL -- mEq/L 'CHLORIDE'
        WHEN itemid = 50902 AND valuenum > 10000 THEN NULL -- mEq/L 'CHLORIDE'
        WHEN itemid = 50912 AND valuenum >   150 THEN NULL -- mg/dL 'CREATININE'
        WHEN itemid = 50809 AND valuenum > 10000 THEN NULL -- mg/dL 'GLUCOSE'
        WHEN itemid = 50931 AND valuenum > 10000 THEN NULL -- mg/dL 'GLUCOSE'
        WHEN itemid = 50810 AND valuenum >   100 THEN NULL -- % 'HEMATOCRIT'
        WHEN itemid = 51221 AND valuenum >   100 THEN NULL -- % 'HEMATOCRIT'
        WHEN itemid = 50811 AND valuenum >    50 THEN NULL -- g/dL 'HEMOGLOBIN'
        WHEN itemid = 51222 AND valuenum >    50 THEN NULL -- g/dL 'HEMOGLOBIN'
        WHEN itemid = 50813 AND valuenum >    50 THEN NULL -- mmol/L 'LACTATE'
        WHEN itemid = 51265 AND valuenum > 10000 THEN NULL -- K/uL 'PLATELET'
        WHEN itemid = 50822 AND valuenum >    30 THEN NULL -- mEq/L 'POTASSIUM'
        WHEN itemid = 50971 AND valuenum >    30 THEN NULL -- mEq/L 'POTASSIUM'
        WHEN itemid = 51275 AND valuenum >   150 THEN NULL -- sec 'PTT'
        WHEN itemid = 51237 AND valuenum >    50 THEN NULL -- 'INR'
        WHEN itemid = 51274 AND valuenum >   150 THEN NULL -- sec 'PT'
        WHEN itemid = 50824 AND valuenum >   200 THEN NULL -- mEq/L == mmol/L 'SODIUM'
        WHEN itemid = 50983 AND valuenum >   200 THEN NULL -- mEq/L == mmol/L 'SODIUM'
        WHEN itemid = 51006 AND valuenum >   300 THEN NULL -- 'BUN'
        WHEN itemid = 51300 AND valuenum >  1000 THEN NULL -- 'WBC'
        WHEN itemid = 51301 AND valuenum >  1000 THEN NULL -- 'WBC'
        ELSE le.valuenum
    END AS valuenum
    FROM `physionet-data.mimic_icu.icustays` ie
    LEFT JOIN `physionet-data.mimic_hosp.labevents` le ON
        le.subject_id = ie.subject_id AND le.hadm_id = ie.hadm_id
        AND le.charttime BETWEEN DATETIME_SUB(ie.intime, INTERVAL '6' HOUR) AND DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
        AND le.ITEMID in
        (
            -- comment is: LABEL | CATEGORY | FLUID | NUMBER OF ROWS IN LABEVENTS
            50868, -- ANION GAP | CHEMISTRY | BLOOD | 3082784
            50862, -- ALBUMIN | CHEMISTRY | BLOOD | 764818
            51144, -- BANDS | Hematology | BlOOD | 242446
            50882, -- BICARBONATE | CHEMISTRY | BLOOD | 3090585
            50885, -- BILIRUBIN, TOTAL | CHEMISTRY | BLOOD | 1304610
            50912, -- CREATININE | CHEMISTRY | BLOOD | 3384150
            50902, -- CHLORIDE | CHEMISTRY | BLOOD | 3207947
            50806, -- CHLORIDE, WHOLE BLOOD | BLOOD GAS | BLOOD | 88451
            50931, -- GLUCOSE | CHEMISTRY | BLOOD | 2834373
            50809, -- GLUCOSE | BLOOD GAS | BLOOD | 221026
            51221, -- HEMATOCRIT | HEMATOLOGY | BLOOD | 3458951
            50810, -- HEMATOCRIT, CALCULATED | BLOOD GAS | BLOOD | 116734
            51222, -- HEMOGLOBIN | HEMATOLOGY | BLOOD | 3306337
            50811, -- HEMOGLOBIN | BLOOD GAS | BLOOD | 116727
            50813, -- LACTATE | BLOOD GAS | BLOOD | 526800
            51265, -- PLATELET COUNT | HEMATOLOGY | BLOOD | 3338356
            50971, -- POTASSIUM | CHEMISTRY | BLOOD | 3275830
            50822, -- POTASSIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 256717
            51275, -- PTT | HEMATOLOGY | BLOOD | 1305999
            51237, -- INR(PT) | HEMATOLOGY | BLOOD | 1449605
            51274, -- PT | HEMATOLOGY | BLOOD | 1448914
            50983, -- SODIUM | CHEMISTRY | BLOOD | 3244333
            50824, -- SODIUM, WHOLE BLOOD | BLOOD GAS | BLOOD | 116638
            51006, -- UREA NITROGEN | CHEMISTRY | BLOOD | 3288488
            51301, -- WHITE BLOOD CELLS | HEMATOLOGY | BLOOD | 3288951
            51300  -- WBC COUNT | HEMATOLOGY | BLOOD | 27183
        )
    AND valuenum IS NOT NULL AND valuenum > 0 -- lab values cannot be 0 AND cannot be negative
)
SELECT
  pvt.subject_id
  , pvt.hadm_id
  , pvt.stay_id
  , MIN(CASE WHEN label = 'ANION GAP' THEN valuenum ELSE NULL END) AS aniongap_min
  , MAX(CASE WHEN label = 'ANION GAP' THEN valuenum ELSE NULL END) AS aniongap_max
  , MIN(CASE WHEN label = 'ALBUMIN' THEN valuenum ELSE NULL END) AS albumin_min
  , MAX(CASE WHEN label = 'ALBUMIN' THEN valuenum ELSE NULL END) AS albumin_max
  , MIN(CASE WHEN label = 'BANDS' THEN valuenum ELSE NULL END) AS bands_min
  , MAX(CASE WHEN label = 'BANDS' THEN valuenum ELSE NULL END) AS bands_max
  , MIN(CASE WHEN label = 'BICARBONATE' THEN valuenum ELSE NULL END) AS bicarbonate_min
  , MAX(CASE WHEN label = 'BICARBONATE' THEN valuenum ELSE NULL END) AS bicarbonate_max
  , MIN(CASE WHEN label = 'BILIRUBIN' THEN valuenum ELSE NULL END) AS bilirubin_min
  , MAX(CASE WHEN label = 'BILIRUBIN' THEN valuenum ELSE NULL END) AS bilirubin_max
  , MIN(CASE WHEN label = 'CREATININE' THEN valuenum ELSE NULL END) AS creatinine_min
  , MAX(CASE WHEN label = 'CREATININE' THEN valuenum ELSE NULL END) AS creatinine_max
  , MIN(CASE WHEN label = 'CHLORIDE' THEN valuenum ELSE NULL END) AS chloride_min
  , MAX(CASE WHEN label = 'CHLORIDE' THEN valuenum ELSE NULL END) AS chloride_max
  , MIN(CASE WHEN label = 'GLUCOSE' THEN valuenum ELSE NULL END) AS glucose_min
  , MAX(CASE WHEN label = 'GLUCOSE' THEN valuenum ELSE NULL END) AS glucose_max
  , MIN(CASE WHEN label = 'HEMATOCRIT' THEN valuenum ELSE NULL END) AS hematocrit_min
  , MAX(CASE WHEN label = 'HEMATOCRIT' THEN valuenum ELSE NULL END) AS hematocrit_max
  , MIN(CASE WHEN label = 'HEMOGLOBIN' THEN valuenum ELSE NULL END) AS hemoglobin_min
  , MAX(CASE WHEN label = 'HEMOGLOBIN' THEN valuenum ELSE NULL END) AS hemoglobin_max
  , MIN(CASE WHEN label = 'LACTATE' THEN valuenum ELSE NULL END) AS lactate_min
  , MAX(CASE WHEN label = 'LACTATE' THEN valuenum ELSE NULL END) AS lactate_max
  , MIN(CASE WHEN label = 'PLATELET' THEN valuenum ELSE NULL END) AS platelet_min
  , MAX(CASE WHEN label = 'PLATELET' THEN valuenum ELSE NULL END) AS platelet_max
  , MIN(CASE WHEN label = 'POTASSIUM' THEN valuenum ELSE NULL END) AS potassium_min
  , MAX(CASE WHEN label = 'POTASSIUM' THEN valuenum ELSE NULL END) AS potassium_max
  , MIN(CASE WHEN label = 'PTT' THEN valuenum ELSE NULL END) AS ptt_min
  , MAX(CASE WHEN label = 'PTT' THEN valuenum ELSE NULL END) AS ptt_max
  , MIN(CASE WHEN label = 'INR' THEN valuenum ELSE NULL END) AS inr_min
  , MAX(CASE WHEN label = 'INR' THEN valuenum ELSE NULL END) AS inr_max
  , MIN(CASE WHEN label = 'PT' THEN valuenum ELSE NULL END) AS pt_min
  , MAX(CASE WHEN label = 'PT' THEN valuenum ELSE NULL END) AS pt_max
  , MIN(CASE WHEN label = 'SODIUM' THEN valuenum ELSE NULL END) AS sodium_min
  , MAX(CASE WHEN label = 'SODIUM' THEN valuenum ELSE NULL END) AS sodium_max
  , MIN(CASE WHEN label = 'BUN' THEN valuenum ELSE NULL END) AS bun_min
  , MAX(CASE WHEN label = 'BUN' THEN valuenum ELSE NULL END) AS bun_max
  , MIN(CASE WHEN label = 'WBC' THEN valuenum ELSE NULL END) AS wbc_min
  , MAX(CASE WHEN label = 'WBC' THEN valuenum ELSE NULL END) AS wbc_max
FROM pvt
GROUP BY pvt.subject_id, pvt.hadm_id, pvt.stay_id
ORDER BY pvt.subject_id, pvt.hadm_id, pvt.stay_id;
