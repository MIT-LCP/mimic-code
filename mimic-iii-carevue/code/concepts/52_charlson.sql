-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
drop table if exists charlson; create table charlson as 
-- ------------------------------------------------------------------
-- This query extracts Charlson Comorbidity Index (CCI) based on the recorded ICD-9 codes.
--
-- Reference for CCI:
-- (1) Charlson ME, Pompei P, Ales KL, MacKenzie CR. (1987) A new method of classifying prognostic 
-- comorbidity in longitudinal studies: development and validation.J Chronic Dis; 40(5):373-83.
--
-- (2) Charlson M, Szatrowski TP, Peterson J, Gold J. (1994) Validation of a combined comorbidity 
-- index. J Clin Epidemiol; 47(11):1245-51.
-- 
-- Reference for ICD-9-CM Coding Algorithm for Charlson Comorbidities:
-- (3) Quan H, Sundararajan V, Halfon P, et al. Coding algorithms for defining Comorbidities in ICD-9-CM
-- and ICD-10 administrative data. Med Care. 2005 Nov; 43(11): 1130-9.
-- ------------------------------------------------------------------

with diag as (
    select
        hadm_id,
        icd9_code
    from
        diagnoses_icd
)

, com as (
    select
        ad.hadm_id

        -- Myocardial infarction
        , max(case when
            substr(icd9_code, 1, 3) in ('410','412')
            then 1 
            else 0 end) as myocardial_infarct

        -- Congestive heart failure
        , max(case when 
            substr(icd9_code, 1, 3) = '428'
            or
            substr(icd9_code, 1, 5) in ('39891','40201','40211','40291','40401','40403','40411','40413','40491','40493')
            or 
            substr(icd9_code, 1, 4) between '4254' and '4259'
            then 1 
            else 0 end) as congestive_heart_failure

        -- Peripheral vascular disease
        , max(case when 
            substr(icd9_code, 1, 3) in ('440','441')
            or
            substr(icd9_code, 1, 4) in ('0930','4373','4471','5571','5579','V434')
            or
            substr(icd9_code, 1, 4) between '4431' and '4439'
            then 1 
            else 0 end) as peripheral_vascular_disease

        -- Cerebrovascular disease
        , max(case when 
            substr(icd9_code, 1, 3) between '430' and '438'
            or
            substr(icd9_code, 1, 5) = '36234'
            then 1 
            else 0 end) as cerebrovascular_disease

        -- Dementia
        , max(case when 
            substr(icd9_code, 1, 3) = '290'
            or
            substr(icd9_code, 1, 4) in ('2941','3312')
            then 1 
            else 0 end) as dementia

        -- Chronic pulmonary disease
        , max(case when 
            substr(icd9_code, 1, 3) between '490' and '505'
            or
            substr(icd9_code, 1, 4) in ('4168','4169','5064','5081','5088')
            then 1 
            else 0 end) as chronic_pulmonary_disease

        -- Rheumatic disease
        , max(case when 
            substr(icd9_code, 1, 3) = '725'
            or
            substr(icd9_code, 1, 4) in ('4465','7100','7101','7102','7103','7104','7140','7141','7142','7148')
            then 1 
            else 0 end) as rheumatic_disease

        -- Peptic ulcer disease
        , max(case when 
            substr(icd9_code, 1, 3) in ('531','532','533','534')
            then 1 
            else 0 end) as peptic_ulcer_disease

        -- Mild liver disease
        , max(case when 
            substr(icd9_code, 1, 3) in ('570','571')
            or
            substr(icd9_code, 1, 4) in ('0706','0709','5733','5734','5738','5739','V427')
            or
            substr(icd9_code, 1, 5) in ('07022','07023','07032','07033','07044','07054')
            then 1 
            else 0 end) as mild_liver_disease

        -- Diabetes without chronic complication
        , max(case when 
            substr(icd9_code, 1, 4) in ('2500','2501','2502','2503','2508','2509')
            then 1 
            else 0 end) as diabetes_without_cc

        -- Diabetes with chronic complication
        , max(case when 
            substr(icd9_code, 1, 4) in ('2504','2505','2506','2507')
            then 1 
            else 0 end) as diabetes_with_cc

        -- Hemiplegia or paraplegia
        , max(case when 
            substr(icd9_code, 1, 3) in ('342','343')
            or
            substr(icd9_code, 1, 4) in ('3341','3440','3441','3442','3443','3444','3445','3446','3449')
            then 1 
            else 0 end) as paraplegia

        -- Renal disease
        , max(case when 
            substr(icd9_code, 1, 3) in ('582','585','586','V56')
            or
            substr(icd9_code, 1, 4) in ('5880','V420','V451')
            or
            substr(icd9_code, 1, 4) between '5830' and '5837'
            or
            substr(icd9_code, 1, 5) in ('40301','40311','40391','40402','40403','40412','40413','40492','40493')
            then 1 
            else 0 end) as renal_disease

        -- Any malignancy, including lymphoma and leukemia, except malignant neoplasm of skin
        , max(case when 
            substr(icd9_code, 1, 3) between '140' and '172'
            or
            substr(icd9_code, 1, 4) between '1740' and '1958'
            or
            substr(icd9_code, 1, 3) between '200' and '208'
            or
            substr(icd9_code, 1, 4) = '2386'
            then 1 
            else 0 end) as malignant_cancer

        -- Moderate or severe liver disease
        , max(case when 
            substr(icd9_code, 1, 4) in ('4560','4561','4562')
            or
            substr(icd9_code, 1, 4) between '5722' and '5728'
            then 1 
            else 0 end) as severe_liver_disease

        -- Metastatic solid tumor
        , max(case when 
            substr(icd9_code, 1, 3) in ('196','197','198','199')
            then 1 
            else 0 end) as metastatic_solid_tumor

        -- AIDS/HIV
        , max(case when 
            substr(icd9_code, 1, 3) in ('042','043','044')
            then 1 
            else 0 end) as aids
    from 
        admissions ad
    left join diag
        on ad.hadm_id = diag.hadm_id
    group by ad.hadm_id
)

, ag as (
    select 
        hadm_id,
        age,
        case when age <= 40 then 0
             when age <= 50 then 1
             when age <= 60 then 2
             when age <= 70 then 3
             else 4 
        end as age_score
    from 
        age
)

select 
    ad.subject_id,
    ad.hadm_id,
    ag.age_score,
    myocardial_infarct,
    congestive_heart_failure,
    peripheral_vascular_disease,
    cerebrovascular_disease,
    dementia,
    chronic_pulmonary_disease,
    rheumatic_disease,
    peptic_ulcer_disease,
    mild_liver_disease,
    diabetes_without_cc,
    diabetes_with_cc,
    paraplegia,
    renal_disease,
    malignant_cancer,
    severe_liver_disease,
    metastatic_solid_tumor,
    aids,
    -- Calculate the Charlson Comorbidity Score using the original
    -- weights from Charlson, 1987.
    age_score
    + myocardial_infarct + congestive_heart_failure + peripheral_vascular_disease
    + cerebrovascular_disease + dementia + chronic_pulmonary_disease
    + rheumatic_disease + peptic_ulcer_disease
    + greatest(mild_liver_disease, 3*severe_liver_disease)
    + greatest(2*diabetes_with_cc, diabetes_without_cc)
    + greatest(2*malignant_cancer, 6*metastatic_solid_tumor)
    + 2*paraplegia + 2*renal_disease 
    + 6*aids
    as charlson_comorbidity_index
from 
    admissions ad
left join com
    on ad.hadm_id = com.hadm_id
left join ag
    on com.hadm_id = ag.hadm_id;