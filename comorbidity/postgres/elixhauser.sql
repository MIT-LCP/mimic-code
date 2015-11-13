-- This query generates the Elixhauser comorbidity score for MIMIC patients

-- First convert the ICD-9 so it has a decimal place
-- Also move any prefix letters to an 'alpha' column
with icd9 as 
(
  SELECT icd.subject_id,
       icd.hadm_id,
       icd9_code as code,
       sequence
       , substring(icd9_code from '[E,V]') as icd9_alpha
       , cast(substring(icd9_code from '[0-9]+') as double precision) as icd9_nodecimal
  FROM mimiciii.diagnoses_icd icd
)
, icd9list AS (
  SELECT icd9.*
	, case 
		when icd9_nodecimal < 1000
			then icd9_nodecimal
		when icd9_nodecimal >= 1000 and icd9_nodecimal < 10000
			then icd9_nodecimal / 10
		when icd9_nodecimal >= 10000
			then icd9_nodecimal / 100
	end as icd9_numeric
  FROM icd9
)
, drglist AS (
  SELECT subject_id, hadm_id
  , drg_type, drg_code
  , cast(drg_code as int) AS codenum
  , description
  FROM mimiciii.drgcodes drg
  WHERE drg_type='HCFA'
)
, drg_category AS 
(
SELECT subject_id,
       hadm_id,
    CASE
      WHEN (drglist.codenum >= 103 AND drglist.codenum <= 108)
      OR (drglist.codenum >= 110 AND drglist.codenum <= 112)
      OR (drglist.codenum >= 115 AND drglist.codenum <= 118)
      OR (drglist.codenum >= 120 AND drglist.codenum <= 127)
      OR drglist.codenum = 129
      OR (drglist.codenum >= 132 AND drglist.codenum <= 133)
      OR (drglist.codenum >= 135 AND drglist.codenum <= 143)
      THEN 1
      ELSE 0
    END AS cardiac,
    CASE
      WHEN (drglist.codenum >= 302 AND drglist.codenum <= 305)
      OR (drglist.codenum >= 315 AND drglist.codenum <= 333)
      THEN 1
      ELSE 0
    END AS renal,
    CASE
      WHEN (drglist.codenum >= 199 AND drglist.codenum <= 202)
      OR (drglist.codenum >= 205 AND drglist.codenum <= 208)
      THEN 1
      ELSE 0
    END AS liver,
    CASE
      WHEN (drglist.codenum >= 400 AND drglist.codenum <= 414)
      OR drglist.codenum = 473
      OR drglist.codenum = 492
      THEN 1
      ELSE 0
    END AS leukemia_lymphoma,
    CASE
      WHEN drglist.codenum = 10
      OR drglist.codenum = 11
      OR drglist.codenum = 64
      OR drglist.codenum = 82
      OR drglist.codenum = 172
      OR drglist.codenum = 173
      OR drglist.codenum = 199
      OR drglist.codenum = 203
      OR drglist.codenum = 239
      OR (drglist.codenum >= 257 AND drglist.codenum <= 260)
      OR drglist.codenum = 274
      OR drglist.codenum = 275
      OR drglist.codenum = 303
      OR drglist.codenum = 318
      OR drglist.codenum = 319
      OR drglist.codenum = 338
      OR drglist.codenum = 344
      OR drglist.codenum = 346
      OR drglist.codenum = 347
      OR drglist.codenum = 354
      OR drglist.codenum = 355
      OR drglist.codenum = 357
      OR drglist.codenum = 363
      OR drglist.codenum = 366
      OR drglist.codenum = 367
      OR (drglist.codenum >= 406 AND drglist.codenum <= 414)
      THEN 1
      ELSE 0
    END AS cancer,
    CASE
      WHEN drglist.codenum = 88
      THEN 1
      ELSE 0
    END AS copd,
    CASE
      WHEN (drglist.codenum >= 130 AND drglist.codenum <= 131)
      THEN 1
      ELSE 0
    END AS peripheral_vascular,
    CASE
      WHEN drglist.codenum = 134
      THEN 1
      ELSE 0
    END AS hypertension,
    CASE
      WHEN (drglist.codenum >= 14 AND drglist.codenum <= 17)
      OR drglist.codenum=5
      THEN 1
      ELSE 0
    END AS cerebrovascular,
    CASE
      WHEN (drglist.codenum >= 1 AND drglist.codenum <= 35)
      THEN 1
      ELSE 0
    END AS nervous_system,
    CASE
      WHEN (drglist.codenum >= 96 AND drglist.codenum <= 98)
      THEN 1
      ELSE 0
    END AS asthma,
    CASE
      WHEN (drglist.codenum >= 294 AND drglist.codenum <= 295)
      THEN 1
      ELSE 0
    END AS diabetes,
    CASE
      WHEN drglist.codenum = 290
      THEN 1
      ELSE 0
    END AS thyroid,
    CASE
      WHEN (drglist.codenum >= 300 AND drglist.codenum <= 301)
      THEN 1
      ELSE 0
    END AS endocrine,
    CASE
      WHEN drglist.codenum = 302
      THEN 1
      ELSE 0
    END AS kidney_transplant,
    CASE
      WHEN (drglist.codenum >= 316 AND drglist.codenum <= 317)
      THEN 1
      ELSE 0
    END AS renal_failure_dialysis,
    CASE
      WHEN (drglist.codenum >= 174 AND drglist.codenum <= 178)
      THEN 1
      ELSE 0
    END AS gi_hemorrhage_ulcer,
    CASE
      WHEN (drglist.codenum >= 488 AND drglist.codenum <= 490)
      THEN 1
      ELSE 0
    END AS hiv,
    CASE
      WHEN (drglist.codenum >= 240 AND drglist.codenum <= 241)
      THEN 1
      ELSE 0
    END AS connective_tissue,
    CASE
      WHEN drglist.codenum = 397
      THEN 1
      ELSE 0
    END AS coagulation,
    CASE
      WHEN drglist.codenum = 288
      THEN 1
      ELSE 0
    END AS obesity_procedure,
    CASE
      WHEN (drglist.codenum >= 396 AND drglist.codenum <= 298)
      THEN 1
      ELSE 0
    END AS nutrition_metabolic,
    CASE
      WHEN (drglist.codenum >= 395 AND drglist.codenum <= 396)
      THEN 1
      ELSE 0
    END AS anemia,
    CASE
      WHEN (drglist.codenum >= 433 AND drglist.codenum <= 437)
      THEN 1
      ELSE 0
    END AS alcohol_drug,
    CASE
      WHEN drglist.codenum = 430
      THEN 1
      ELSE 0
    END AS psychoses,
    CASE
      WHEN drglist.codenum = 426
      THEN 1
      ELSE 0
    END AS depression
  FROM drglist
) 
, elixhauser AS 
(
SELECT icd.subject_id,
       icd.hadm_id,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric = 398.91
        OR icd.icd9_numeric = 402.11
        OR icd.icd9_numeric = 402.91
        OR icd.icd9_numeric = 404.11
        OR icd.icd9_numeric = 404.13
        OR icd.icd9_numeric = 404.91
        OR icd.icd9_numeric = 404.93
        OR icd.icd9_numeric BETWEEN 428 AND 428.9)
        AND drg.cardiac = 0
        THEN 1
        ELSE 0
      END
      ) AS congestive_heart_failure,
      MAX(
      CASE
        WHEN ((icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric = 426.1
        OR icd.icd9_numeric = 426.11
        OR icd.icd9_numeric = 426.13
        OR icd.icd9_numeric BETWEEN 426.2 AND 426.53
        OR icd.icd9_numeric BETWEEN 426.6 AND 426.89
        OR icd.icd9_numeric = 427
        OR icd.icd9_numeric = 427.2
        OR icd.icd9_numeric = 427.31
        OR icd.icd9_numeric = 427.6
        OR icd.icd9_numeric = 427.9
        OR icd.icd9_numeric = 785))
        OR (icd.icd9_alpha = 'V'
        AND (icd.icd9_numeric = 45
        OR icd.icd9_numeric = 53.3)))
        AND drg.cardiac = 0
        THEN 1
        ELSE 0
      END
      ) AS cardiac_arrhythmias,
      MAX(
      CASE
        WHEN ((icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 93.2 AND 93.24
        OR icd.icd9_numeric BETWEEN 394 AND 397.1
        OR icd.icd9_numeric BETWEEN 424 AND 424.91
        OR icd.icd9_numeric BETWEEN 746.3 AND 746.6))
        OR (icd.icd9_alpha = 'V'
        AND (icd.icd9_numeric = 42.2
        OR icd.icd9_numeric = 43.3)))
        AND drg.cardiac = 0
        THEN 1
        ELSE 0
      END
      ) AS valvular_disease,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 416 AND 416.9
        OR icd.icd9_numeric = 417.9)
        AND (drg.cardiac = 0 AND drg.copd = 0)
        THEN 1
        ELSE 0
      END
      ) AS pulmonary_circulation,
      MAX(
      CASE
        WHEN ((icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 440 AND 440.9
        OR icd.icd9_numeric = 441.2
        OR icd.icd9_numeric = 441.4
        OR icd.icd9_numeric = 441.7
        OR icd.icd9_numeric = 441.9
        OR icd.icd9_numeric BETWEEN 443.1 AND 443.9
        OR icd.icd9_numeric = 447.1
        OR icd.icd9_numeric = 557.1
        OR icd.icd9_numeric = 557.9))
        OR (icd.icd9_alpha = 'V'
        AND icd.icd9_numeric = 43.4))
        AND drg.peripheral_vascular = 0
        THEN 1
        ELSE 0
      END
      ) AS peripheral_vascular,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric = 401.1
        OR icd.icd9_numeric = 401.9
        OR icd.icd9_numeric = 402.1
        OR icd.icd9_numeric = 402.9
        OR icd.icd9_numeric = 404.1
        OR icd.icd9_numeric = 404.9
        OR icd.icd9_numeric = 405.11
        OR icd.icd9_numeric = 405.19
        OR icd.icd9_numeric = 405.91
        OR icd.icd9_numeric = 405.99)
        AND (drg.hypertension = 0 AND drg.cardiac = 0 AND drg.renal = 0)
        THEN 1
        ELSE 0
      END
      ) AS hypertension,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 342 AND 342.12
        OR icd.icd9_numeric BETWEEN 342.9 AND 344.9)
        AND drg.cerebrovascular = 0
        THEN 1
        ELSE 0
      END
      ) AS paralysis,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric = 331.9
        OR icd.icd9_numeric = 332
        OR icd.icd9_numeric = 333.4
        OR icd.icd9_numeric = 333.5
        OR icd.icd9_numeric BETWEEN 334 AND 335.9
        OR icd.icd9_numeric = 340
        OR icd.icd9_numeric BETWEEN 341.1 AND 341.9
        OR icd.icd9_numeric BETWEEN 345 AND 345.11
        OR icd.icd9_numeric BETWEEN 345.4 AND 345.51
        OR icd.icd9_numeric BETWEEN 345.8 AND 345.91
        OR icd.icd9_numeric = 348.1
        OR icd.icd9_numeric = 348.3
        OR icd.icd9_numeric = 780.3
        OR icd.icd9_numeric = 784.3)
        AND drg.nervous_system = 0
        THEN 1
        ELSE 0
      END
      ) AS other_neurological,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 490 AND 492.8
        OR icd.icd9_numeric BETWEEN 493 AND 493.91
        OR icd.icd9_numeric = 494
        OR icd.icd9_numeric BETWEEN 495 AND 505
        OR icd.icd9_numeric = 506.4)
        AND (drg.copd = 0 AND drg.asthma = 0)
        THEN 1
        ELSE 0
      END
      ) AS chronic_pulmonary,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND icd.icd9_numeric BETWEEN 250 AND 250.33        
        AND drg.diabetes = 0
        THEN 1
        ELSE 0
      END
      ) AS diabetes_uncomplicated,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 250.4 AND 250.73
        OR icd.icd9_numeric BETWEEN 250.9 AND 250.93)
        AND drg.diabetes = 0
        THEN 1
        ELSE 0
      END
      ) AS diabetes_complicated,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 243 AND 244.2
        OR icd.icd9_numeric = 244.8
        OR icd.icd9_numeric = 244.9)
        AND (drg.thyroid = 0 AND drg.endocrine = 0)
        THEN 1
        ELSE 0
      END
      ) AS hypothyroidism,
      MAX(
      CASE
        WHEN ((icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric = 403.11 
        OR icd.icd9_numeric = 403.91
        OR icd.icd9_numeric = 404.12
        OR icd.icd9_numeric = 404.92
        OR icd.icd9_numeric = 585
        OR icd.icd9_numeric = 586))
        OR (icd.icd9_alpha = 'V'
        AND (icd.icd9_numeric = 42
        OR icd.icd9_numeric = 45.1
        OR icd.icd9_numeric = 56
        OR icd.icd9_numeric = 56.8)))
        AND (drg.kidney_transplant = 0 AND renal_failure_dialysis = 0)
        THEN 1
        ELSE 0
      END
      ) AS renal_failure,
      MAX(
      CASE
        WHEN ((icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric = 70.32
        OR icd.icd9_numeric = 70.33
        OR icd.icd9_numeric = 70.54
        OR icd.icd9_numeric = 456
        OR icd.icd9_numeric = 456.1
        OR icd.icd9_numeric = 456.2
        OR icd.icd9_numeric = 456.21
        OR icd.icd9_numeric = 571
        OR icd.icd9_numeric = 571.2
        OR icd.icd9_numeric = 571.3
        OR icd.icd9_numeric BETWEEN 571.4 AND 571.49
        OR icd.icd9_numeric = 571.5
        OR icd.icd9_numeric = 571.6
        OR icd.icd9_numeric = 571.8
        OR icd.icd9_numeric = 571.9
        OR icd.icd9_numeric = 572.3
        OR icd.icd9_numeric = 572.8))
        OR (icd.icd9_alpha = 'V'
        AND icd.icd9_numeric = 42.7))
        AND drg.liver = 0
        THEN 1
        ELSE 0
      END
      ) AS liver_disease,
      MAX(
      CASE
        WHEN ((icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric = 531.7
        OR icd.icd9_numeric = 531.9
        OR icd.icd9_numeric = 532.7
        OR icd.icd9_numeric = 532.9
        OR icd.icd9_numeric = 533.7
        OR icd.icd9_numeric = 533.9
        OR icd.icd9_numeric = 534.7
        OR icd.icd9_numeric = 534.9))
        OR (icd.icd9_alpha = 'V'
        AND icd.icd9_numeric = 12.71))
        AND drg.gi_hemorrhage_ulcer = 0
        THEN 1
        ELSE 0
      END
      ) AS peptic_ulcer,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND icd.icd9_numeric BETWEEN 42 AND 44.9        
        AND drg.hiv = 0
        THEN 1
        ELSE 0
      END
      ) AS aids,
      MAX(
      CASE
        WHEN ((icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 200 AND 202.38 
        OR icd.icd9_numeric BETWEEN 202.5 AND 203.01
        OR icd.icd9_numeric BETWEEN 203.8 AND 203.81
        OR icd.icd9_numeric = 238.6
        OR icd.icd9_numeric = 273.3))
        OR (icd.icd9_alpha = 'V'
        AND (icd.icd9_numeric = 10.71
        OR icd.icd9_numeric = 10.72
        OR icd.icd9_numeric = 10.79)))
        AND drg.leukemia_lymphoma = 0
        THEN 1
        ELSE 0
      END
      ) AS lymphoma,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND icd.icd9_numeric BETWEEN 196 AND 199.1        
        AND drg.cancer = 0
        THEN 1
        ELSE 0
      END
      ) AS metastatic_cancer,
      MAX(
      CASE
        WHEN ((icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 140 AND 172.9
        OR icd.icd9_numeric BETWEEN 174 AND 175.9
        OR icd.icd9_numeric BETWEEN 179 AND 195.8))
        OR (icd.icd9_alpha = 'V'
        AND icd.icd9_numeric BETWEEN 10 AND 10.9))
        AND drg.cancer = 0
        THEN 1
        ELSE 0
      END
      ) AS solid_tumor,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric = 701
        OR icd.icd9_numeric BETWEEN 710 AND 710.9
        OR icd.icd9_numeric BETWEEN 714 AND 714.9
        OR icd.icd9_numeric BETWEEN 720 AND 720.9
        OR icd.icd9_numeric = 725)
        AND drg.connective_tissue = 0
        THEN 1
        ELSE 0
      END
      ) AS rheumatoid_arthritis,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 2860 AND 2869
        OR icd.icd9_numeric = 287.1
        OR icd.icd9_numeric BETWEEN 287.3 AND 287.5)
        AND drg.coagulation = 0
        THEN 1
        ELSE 0
      END
      ) AS coagulopathy,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND icd.icd9_numeric = 278        
        AND (drg.obesity_procedure = 0 AND drg.nutrition_metabolic = 0)
        THEN 1
        ELSE 0
      END
      ) AS obesity,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND icd.icd9_numeric BETWEEN 260 AND 263.9        
        AND drg.nutrition_metabolic = 0
        THEN 1
        ELSE 0
      END
      ) AS weight_loss,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND icd.icd9_numeric BETWEEN 276 AND 276.9        
        AND drg.nutrition_metabolic = 0
        THEN 1
        ELSE 0
      END
      ) AS fluid_electrolyte,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND icd.icd9_numeric = 2800        
        AND drg.anemia = 0
        THEN 1
        ELSE 0
      END
      ) AS blood_loss_anemia,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 280.1 AND 281.9
        OR icd.icd9_numeric = 285.9)
        AND drg.anemia = 0
        THEN 1
        ELSE 0
      END
      ) AS deficiency_anemias,
      MAX(
      CASE
        WHEN ((icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric = 291.1
        OR icd.icd9_numeric = 291.2
        OR icd.icd9_numeric = 291.5
        OR icd.icd9_numeric = 291.8
        OR icd.icd9_numeric = 291.9
        OR icd.icd9_numeric BETWEEN 303.9 AND 303.93
        OR icd.icd9_numeric BETWEEN 305 AND 305.03))
        OR (icd.icd9_alpha = 'V'
        AND icd.icd9_numeric = 113))
        AND drg.alcohol_drug = 0
        THEN 1
        ELSE 0
      END
      ) AS alcohol_abuse,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric = 292
        OR icd.icd9_numeric BETWEEN 292.82 AND 292.89
        OR icd.icd9_numeric = 292.9
        OR icd.icd9_numeric BETWEEN 304 AND 304.93
        OR icd.icd9_numeric BETWEEN 305.2 AND 305.93)
        AND drg.alcohol_drug = 0
        THEN 1
        ELSE 0
      END
      ) AS drug_abuse,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric BETWEEN 295 AND 298.9
        OR icd.icd9_numeric BETWEEN 299.1 AND 299.11)
        AND drg.psychoses = 0
        THEN 1
        ELSE 0
      END
      ) AS psychoses,
      MAX(
      CASE
        WHEN icd.icd9_alpha IS NULL
        AND (icd.icd9_numeric = 300.4
        OR icd.icd9_numeric = 301.12
        OR icd.icd9_numeric = 309
        OR icd.icd9_numeric = 309.1
        OR icd.icd9_numeric = 311)
        AND drg.depression = 0
        THEN 1
        ELSE 0
      END
      ) AS depression
    FROM icd9list icd, drg_category drg
    WHERE icd.hadm_id = drg.hadm_id
    GROUP BY icd.subject_id, icd.hadm_id
)
SELECT 
adm.SUBJECT_ID,
adm.HADM_ID,
-- point scores for various recalibrations of elixhauser...

-- in-hospital mortality
CONGESTIVE_HEART_FAILURE*(4) + CARDIAC_ARRHYTHMIAS*(4) + VALVULAR_DISEASE*(-3) + PULMONARY_CIRCULATION*(0) +
PERIPHERAL_VASCULAR     *(0) + HYPERTENSION*(-1) + PARALYSIS*(0) +
OTHER_NEUROLOGICAL      *(7) + CHRONIC_PULMONARY*(0) +
DIABETES_UNCOMPLICATED  *(-1) + DIABETES_COMPLICATED*(-4) +
HYPOTHYROIDISM          *(0) + RENAL_FAILURE*(3) + LIVER_DISEASE*(4) +
PEPTIC_ULCER            *(-9) + AIDS*(0) + LYMPHOMA*(7) +
METASTATIC_CANCER       *(9) + SOLID_TUMOR*(0) + RHEUMATOID_ARTHRITIS*(0) + 
COAGULOPATHY*(3) + OBESITY*(-5) + WEIGHT_LOSS*(4)                      + FLUID_ELECTROLYTE*(6) + BLOOD_LOSS_ANEMIA*(0) +
DEFICIENCY_ANEMIAS      *(-4) + ALCOHOL_ABUSE*(0) + DRUG_ABUSE*(-6) +
PSYCHOSES               *(-5) + DEPRESSION*(-8) 
AS elixhauser_hospital,

-- 28 day mortality
CONGESTIVE_HEART_FAILURE*(5) + CARDIAC_ARRHYTHMIAS*(4) + VALVULAR_DISEASE*(-1) + 
PULMONARY_CIRCULATION*(0) +
PERIPHERAL_VASCULAR     *(0) + HYPERTENSION*(-1) + PARALYSIS*(0) +
OTHER_NEUROLOGICAL      *(6) + CHRONIC_PULMONARY*(0) +
DIABETES_UNCOMPLICATED  *(0) + DIABETES_COMPLICATED*(-3) + HYPOTHYROIDISM*(0) + 
RENAL_FAILURE*(4) + LIVER_DISEASE*(4) +
PEPTIC_ULCER            *(0) + AIDS*(0) + LYMPHOMA*(5) +
METASTATIC_CANCER       *(12) + SOLID_TUMOR*(1) + RHEUMATOID_ARTHRITIS*(0) + 
COAGULOPATHY*(3) + OBESITY*(-6) + WEIGHT_LOSS*(6) + 
FLUID_ELECTROLYTE*(6) + BLOOD_LOSS_ANEMIA*(0) +
DEFICIENCY_ANEMIAS      *(-3) + ALCOHOL_ABUSE*(-2) + DRUG_ABUSE*(-6) +
PSYCHOSES               *(-4) + DEPRESSION*(-6) 
AS elixhauser_28day,

CONGESTIVE_HEART_FAILURE,
CARDIAC_ARRHYTHMIAS,
VALVULAR_DISEASE,
PULMONARY_CIRCULATION,
PERIPHERAL_VASCULAR,
HYPERTENSION,
PARALYSIS,
OTHER_NEUROLOGICAL,
CHRONIC_PULMONARY,
DIABETES_UNCOMPLICATED,
DIABETES_COMPLICATED,
HYPOTHYROIDISM,
RENAL_FAILURE,
LIVER_DISEASE,
PEPTIC_ULCER,
AIDS,
LYMPHOMA,
METASTATIC_CANCER,
SOLID_TUMOR,
RHEUMATOID_ARTHRITIS,
COAGULOPATHY,
OBESITY,
WEIGHT_LOSS,
FLUID_ELECTROLYTE,
BLOOD_LOSS_ANEMIA,
DEFICIENCY_ANEMIAS,
ALCOHOL_ABUSE,
DRUG_ABUSE,
PSYCHOSES,
DEPRESSION

FROM mimiciii.admissions adm
left join elixhauser eli
	on adm.subject_id = eli.subject_id and adm.hadm_id = eli.hadm_id;