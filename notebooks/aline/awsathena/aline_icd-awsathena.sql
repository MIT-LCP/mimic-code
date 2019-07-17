-- Extract data which is based on ICD-9 codes
CREATE TABLE DATABASE.ALINE_ICD AS
select
  co.hadm_id
  , max(case when icd9_code in
  (  '03642','07422','09320','09321','09322','09323','09324','09884'
    ,'11281','11504','11514','11594'
    ,' 3911',' 4210',' 4211',' 4219'
    ,'42490','42491','42499'
  ) then 1 else 0 end) as endocarditis

  -- chf
  , max(case when icd9_code in
  (  '39891','40201','40291','40491','40413'
    ,'40493','4280 ','4281 ','42820','42821'
    ,'42822','42823','42830','42831','42832'
    ,'42833','42840','42841','42842','42843'
    ,'4289 ','428  ','4282 ','4283 ','4284 '
  ) then 1 else 0 end) as chf

  -- atrial fibrilliation or atrial flutter
  , max(case when icd9_code like '4273%' then 1 else 0 end) as afib

  -- renal
  , max(case when icd9_code like '585%' then 1 else 0 end) as renal

  -- liver
  , max(case when icd9_code like '571%' then 1 else 0 end) as liver

  -- copd
  , max(case when icd9_code in
  (  '4660 ','490  ','4910 ','4911 ','49120'
    ,'49121','4918 ','4919 ','4920 ','4928 '
    ,'494  ','4940 ','4941 ','496  ') then 1 else 0 end) as copd

  -- coronary artery disease
  , max(case when icd9_code like '414%' then 1 else 0 end) as cad

  -- stroke
  , max(case when icd9_code like '430%'
      or icd9_code like '431%'
      or icd9_code like '432%'
      or icd9_code like '433%'
      or icd9_code like '434%'
       then 1 else 0 end) as stroke

  -- malignancy, includes remissions
  , max(case when icd9_code between '140' and '239' then 1 else 0 end) as malignancy

  -- resp failure
  , max(case when icd9_code like '518%' then 1 else 0 end) as respfail

  -- ARDS
  , max(case when icd9_code = '51882' or icd9_code = '5185 ' then 1 else 0 end) as ards

  -- pneumonia
  , max(case when icd9_code between '486' and '48881'
      or icd9_code between '480' and '48099'
      or icd9_code between '482' and '48299'
      or icd9_code between '506' and '5078'
        then 1 else 0 end) as pneumonia
from DATABASE.aline_cohort co
left join DATABASE.diagnoses_icd icd
  on co.hadm_id = icd.hadm_id
group by co.hadm_id
order by co.hadm_id;
