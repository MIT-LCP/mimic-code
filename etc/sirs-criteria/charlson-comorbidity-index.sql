-- converts all icd9_code to 5-digit format so that we can compare them accurately
CREATE VIEW a_5digit_icd9 AS
select subject_id,hadm_id,
CASE WHEN length(d.icd9_code) <> 5 THEN rpad(d.icd9_code,5,'0') ELSE d.icd9_code END AS icd9_code
from diagnoses_icd d
UNION
select subject_id,hadm_id,
'P3848' AS icd9_code
from procedures_icd p
where icd9_code = '3848'
;


-- calculates Charlson Comorbidity Index
CREATE TABLE a_Charlson_Index AS 
with tmp as
(
select subject_id, hadm_id, icd9_code
,case when (icd9_code between '41000' AND '41099') OR (icd9_code = '41200') then 1 else 0 end as MI -- 412.X
,case when (icd9_code between '42800' AND '42899') then 1 else 0 end as CHF
,case when (icd9_code between '44100' AND '44199') OR (icd9_code between '44390' AND '44399') OR (icd9_code IN ('P3848','V4340','78540')) then 1 else 0 end as PVD --44390
,case when (icd9_code between '43000' AND '43799') OR (icd9_code IN ('43813','43814')) then 1 else 0 end as CVD --430.x-438.x
,case when (icd9_code between '29000' AND '29099') then 1 else 0 end as DEMENTIA
,case when (icd9_code between '49000' AND '49699') OR (icd9_code between '50000' AND '50599') OR (icd9_code = '50640') then 1 else 0 end as COPD -- 490.x-505.x
,case when (icd9_code IN ('71000','71010','71040','71481','72500')) OR (icd9_code between '71400' AND '71429') then 1 else 0 end as RHEUM --connective tissue disease
,case when (icd9_code between '53100' AND '53499') then 1 else 0 end as PUD
,case when (icd9_code IN ('57120', '57150', '57160')) OR (icd9_code between '57140' AND '57149') then 1 else 0 end as MILD_LIVER --
,case when (icd9_code between '25000' AND '25039') OR (icd9_code = '25070') then 1 else 0 end as DM -- Diabetes Mellitus
,case when (icd9_code between '25040' AND '25069') then 1 else 0 end as DM_COMP  --Leukemia
,case when (icd9_code = '34410') OR (icd9_code between '34200' AND '34299') then 1 else 0 end as PLEGIA 
,case when (icd9_code between '58200' AND '58299') OR (icd9_code between '58300' AND '58379') OR (icd9_code between '58500' AND '58599') OR (icd9_code = '58600') OR (icd9_code between '58800' AND '58899') then 1 else 0 end as RENAL --Moderate to severe Chronic Kidney Disease
,case when (icd9_code between '14000' AND '17299') OR (icd9_code between '17400' AND '19589') OR (icd9_code between '20000' AND '20899') then 1 else 0 end as MALIGNANCY
,case when (icd9_code between '57220' AND '57289') OR (icd9_code between '45600' AND '45621') then 1 else 0 end as SEVERE_LIVER
,case when (icd9_code between '19600' AND '19919') then 1 else 0 end as METASTASIS --Solid Tumor
,case when (icd9_code between '04200' AND '04493') then 1 else 0 end as HIV 
from a_5digit_icd9
)
, max_vals as
(
select subject_id, hadm_id
,max(MI) AS MI
,max(CHF) AS CHF
,max(PVD) AS PVD
,max(CVD) AS CVD
,max(DEMENTIA) AS DEMENTIA
,max(COPD) AS COPD
,max(RHEUM) AS RHEUM
,max(PUD) AS PUD
,max(MILD_LIVER) AS MILD_LIVER
,max(DM) AS DM
,max(DM_COMP) AS DM_COMP
,max(PLEGIA) AS PLEGIA
,max(RENAL) AS RENAL
,max(MALIGNANCY) AS MALIGNANCY
,max(SEVERE_LIVER) AS SEVERE_LIVER
,max(METASTASIS) AS METASTASIS
,max(HIV) AS HIV
from tmp
group by subject_id, hadm_id
)
, filter as
(
select subject_id, hadm_id
,MI
,CHF
,PVD
,CVD
,DEMENTIA
,COPD
,RHEUM
,PUD
,case when SEVERE_LIVER=1 then 0 else MILD_LIVER end as MILD_LIVER
,case when DM_COMP=1 then 0 else DM end as DM
,DM_COMP
,PLEGIA
,RENAL
,case when METASTASIS=1 then 0 else MALIGNANCY end as MALIGNANCY
,SEVERE_LIVER
,METASTASIS
,HIV
from max_vals
)
select subject_id, hadm_id,
(1*MI+1*CHF+1*PVD+1*CVD+1*DEMENTIA+1*COPD+1*RHEUM+1*PUD+1*MILD_LIVER+1*DM+2*DM_COMP+1*PLEGIA+2*RENAL+2*MALIGNANCY+3*SEVERE_LIVER+6*METASTASIS+6*HIV) AS CCI
from filter;

