-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.elixhauser_quan; CREATE TABLE mimiciii_derived.elixhauser_quan AS
/* This code calculates the Elixhauser comorbidities as defined in Quan et. al 2009: */ /* Quan, Hude, et al. "Coding algorithms for defining comorbidities in */ /* ICD-9-CM and ICD-10 administrative data." Medical care (2005): 1130-1139. */ /*  https://www.ncbi.nlm.nih.gov/pubmed/16224307 */ /* Quan defined an "Enhanced ICD-9" coding scheme for deriving Elixhauser */ /* comorbidities from ICD-9 billing codes. This script implements that calculation. */ /* The logic of the code is roughly that, if the comorbidity lists a length 3 */ /* ICD-9 code (e.g. 585), then we only require a match on the first 3 characters. */ /* This code derives each comorbidity as follows: */ /*  1) ICD9_CODE is directly compared to 5 character codes */ /*  2) The first 4 characters of ICD9_CODE are compared to 4 character codes */ /*  3) The first 3 characters of ICD9_CODE are compared to 3 character codes */
WITH eliflg AS (
  SELECT
    hadm_id,
    seq_num,
    icd9_code,
    CASE
      WHEN icd9_code IN (
        '39891',
        '40201',
        '40211',
        '40291',
        '40401',
        '40403',
        '40411',
        '40413',
        '40491',
        '40493'
      )
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('4254', '4255', '4257', '4258', '4259')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('428')
      THEN 1
      ELSE 0
    END AS chf, /* Congestive heart failure */
    CASE
      WHEN icd9_code IN ('42613', '42610', '42612', '99601', '99604')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN (
        '4260',
        '4267',
        '4269',
        '4270',
        '4271',
        '4272',
        '4273',
        '4274',
        '4276',
        '4278',
        '4279',
        '7850',
        'V450',
        'V533'
      )
      THEN 1
      ELSE 0
    END AS arrhy,
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('0932', '7463', '7464', '7465', '7466', 'V422', 'V433')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('394', '395', '396', '397', '424')
      THEN 1
      ELSE 0
    END AS valve, /* Valvular disease */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('4150', '4151', '4170', '4178', '4179')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('416')
      THEN 1
      ELSE 0
    END AS pulmcirc, /* Pulmonary circulation disorder */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('0930', '4373', '4431', '4432', '4438', '4439', '4471', '5571', '5579', 'V434')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('440', '441')
      THEN 1
      ELSE 0
    END AS perivasc, /* Peripheral vascular disorder */
    CASE WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('401') THEN 1 ELSE 0 END AS htn, /* Hypertension, uncomplicated */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('402', '403', '404', '405')
      THEN 1
      ELSE 0
    END AS htncx, /* Hypertension, complicated */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('3341', '3440', '3441', '3442', '3443', '3444', '3445', '3446', '3449')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('342', '343')
      THEN 1
      ELSE 0
    END AS para, /* Paralysis */
    CASE
      WHEN icd9_code IN ('33392')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('3319', '3320', '3321', '3334', '3335', '3362', '3481', '3483', '7803', '7843')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('334', '335', '340', '341', '345')
      THEN 1
      ELSE 0
    END AS neuro, /* Other neurological */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('4168', '4169', '5064', '5081', '5088')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN (
        '490',
        '491',
        '492',
        '493',
        '494',
        '495',
        '496',
        '500',
        '501',
        '502',
        '503',
        '504',
        '505'
      )
      THEN 1
      ELSE 0
    END AS chrnlung, /* Chronic pulmonary disease */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('2500', '2501', '2502', '2503')
      THEN 1
      ELSE 0
    END AS dm, /* Diabetes w/o chronic complications */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('2504', '2505', '2506', '2507', '2508', '2509')
      THEN 1
      ELSE 0
    END AS dmcx, /* Diabetes w/ chronic complications */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('2409', '2461', '2468')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('243', '244')
      THEN 1
      ELSE 0
    END AS hypothy, /* Hypothyroidism */
    CASE
      WHEN icd9_code IN ('40301', '40311', '40391', '40402', '40403', '40412', '40413', '40492', '40493')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('5880', 'V420', 'V451')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('585', '586', 'V56')
      THEN 1
      ELSE 0
    END AS renlfail, /* Renal failure */
    CASE
      WHEN icd9_code IN ('07022', '07023', '07032', '07033', '07044', '07054')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN (
        '0706',
        '0709',
        '4560',
        '4561',
        '4562',
        '5722',
        '5723',
        '5724',
        '5728',
        '5733',
        '5734',
        '5738',
        '5739',
        'V427'
      )
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('570', '571')
      THEN 1
      ELSE 0
    END AS liver, /* Liver disease */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('5317', '5319', '5327', '5329', '5337', '5339', '5347', '5349')
      THEN 1
      ELSE 0
    END AS ulcer, /* Chronic Peptic ulcer disease (includes bleeding only if obstruction is also present) */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('042', '043', '044')
      THEN 1
      ELSE 0
    END AS aids, /* HIV and AIDS */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('2030', '2386')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('200', '201', '202')
      THEN 1
      ELSE 0
    END AS lymph, /* Lymphoma */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('196', '197', '198', '199')
      THEN 1
      ELSE 0
    END AS mets, /* Metastatic cancer */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN (
        '140',
        '141',
        '142',
        '143',
        '144',
        '145',
        '146',
        '147',
        '148',
        '149',
        '150',
        '151',
        '152',
        '153',
        '154',
        '155',
        '156',
        '157',
        '158',
        '159',
        '160',
        '161',
        '162',
        '163',
        '164',
        '165',
        '166',
        '167',
        '168',
        '169',
        '170',
        '171',
        '172',
        '174',
        '175',
        '176',
        '177',
        '178',
        '179',
        '180',
        '181',
        '182',
        '183',
        '184',
        '185',
        '186',
        '187',
        '188',
        '189',
        '190',
        '191',
        '192',
        '193',
        '194',
        '195'
      )
      THEN 1
      ELSE 0
    END AS tumor, /* Solid tumor without metastasis */
    CASE
      WHEN icd9_code IN ('72889', '72930')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN (
        '7010',
        '7100',
        '7101',
        '7102',
        '7103',
        '7104',
        '7108',
        '7109',
        '7112',
        '7193',
        '7285'
      )
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('446', '714', '720', '725')
      THEN 1
      ELSE 0
    END AS arth, /* Rheumatoid arthritis/collagen vascular diseases */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('2871', '2873', '2874', '2875')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('286')
      THEN 1
      ELSE 0
    END AS coag, /* Coagulation deficiency */
    CASE WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('2780') THEN 1 ELSE 0 END AS obese, /* Obesity      */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('7832', '7994')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('260', '261', '262', '263')
      THEN 1
      ELSE 0
    END AS wghtloss, /* Weight loss */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('2536')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('276')
      THEN 1
      ELSE 0
    END AS lytes, /* Fluid and electrolyte disorders */
    CASE WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('2800') THEN 1 ELSE 0 END AS bldloss, /* Blood loss anemia */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('2801', '2808', '2809')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('281')
      THEN 1
      ELSE 0
    END AS anemdef, /* Deficiency anemias */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN (
        '2652',
        '2911',
        '2912',
        '2913',
        '2915',
        '2918',
        '2919',
        '3030',
        '3039',
        '3050',
        '3575',
        '4255',
        '5353',
        '5710',
        '5711',
        '5712',
        '5713',
        'V113'
      )
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('980')
      THEN 1
      ELSE 0
    END AS alcohol, /* Alcohol abuse */
    CASE
      WHEN icd9_code IN ('V6542')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('3052', '3053', '3054', '3055', '3056', '3057', '3058', '3059')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('292', '304')
      THEN 1
      ELSE 0
    END AS drug, /* Drug abuse */
    CASE
      WHEN icd9_code IN ('29604', '29614', '29644', '29654')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('2938')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('295', '297', '298')
      THEN 1
      ELSE 0
    END AS psych, /* Psychoses */
    CASE
      WHEN SUBSTRING(icd9_code FROM 1 FOR 4) IN ('2962', '2963', '2965', '3004')
      THEN 1
      WHEN SUBSTRING(icd9_code FROM 1 FOR 3) IN ('309', '311')
      THEN 1
      ELSE 0
    END AS depress /* Depression */
  FROM mimiciii.diagnoses_icd AS icd
  WHERE
    seq_num <> 1 /* we do not include the primary icd-9 code */
), eligrp /* collapse the icd9_code specific flags into hadm_id specific flags */ /* this groups comorbidities together for a single patient admission */ AS (
  SELECT
    hadm_id,
    MAX(chf) AS chf,
    MAX(arrhy) AS arrhy,
    MAX(valve) AS valve,
    MAX(pulmcirc) AS pulmcirc,
    MAX(perivasc) AS perivasc,
    MAX(htn) AS htn,
    MAX(htncx) AS htncx,
    MAX(para) AS para,
    MAX(neuro) AS neuro,
    MAX(chrnlung) AS chrnlung,
    MAX(dm) AS dm,
    MAX(dmcx) AS dmcx,
    MAX(hypothy) AS hypothy,
    MAX(renlfail) AS renlfail,
    MAX(liver) AS liver,
    MAX(ulcer) AS ulcer,
    MAX(aids) AS aids,
    MAX(lymph) AS lymph,
    MAX(mets) AS mets,
    MAX(tumor) AS tumor,
    MAX(arth) AS arth,
    MAX(coag) AS coag,
    MAX(obese) AS obese,
    MAX(wghtloss) AS wghtloss,
    MAX(lytes) AS lytes,
    MAX(bldloss) AS bldloss,
    MAX(anemdef) AS anemdef,
    MAX(alcohol) AS alcohol,
    MAX(drug) AS drug,
    MAX(psych) AS psych,
    MAX(depress) AS depress
  FROM eliflg
  GROUP BY
    hadm_id
)
/* now merge these flags together to define elixhauser */ /* most are straightforward.. but hypertension flags are a bit more complicated */
SELECT
  adm.hadm_id,
  chf AS congestive_heart_failure,
  arrhy AS cardiac_arrhythmias,
  valve AS valvular_disease,
  pulmcirc AS pulmonary_circulation,
  perivasc AS peripheral_vascular, /* we combine "htn" and "htncx" into "HYPERTENSION" */
  CASE WHEN htn = 1 THEN 1 WHEN htncx = 1 THEN 1 ELSE 0 END AS hypertension,
  para AS paralysis,
  neuro AS other_neurological,
  chrnlung AS chronic_pulmonary, /* only the more severe comorbidity (complicated diabetes) is kept */
  CASE WHEN dmcx = 1 THEN 0 WHEN dm = 1 THEN 1 ELSE 0 END AS diabetes_uncomplicated,
  dmcx AS diabetes_complicated,
  hypothy AS hypothyroidism,
  renlfail AS renal_failure,
  liver AS liver_disease,
  ulcer AS peptic_ulcer,
  aids AS aids,
  lymph AS lymphoma,
  mets AS metastatic_cancer, /* only the more severe comorbidity (metastatic cancer) is kept */
  CASE WHEN mets = 1 THEN 0 WHEN tumor = 1 THEN 1 ELSE 0 END AS solid_tumor,
  arth AS rheumatoid_arthritis,
  coag AS coagulopathy,
  obese AS obesity,
  wghtloss AS weight_loss,
  lytes AS fluid_electrolyte,
  bldloss AS blood_loss_anemia,
  anemdef AS deficiency_anemias,
  alcohol AS alcohol_abuse,
  drug AS drug_abuse,
  psych AS psychoses,
  depress AS depression
FROM mimiciii.admissions AS adm
LEFT JOIN eligrp AS eli
  ON adm.hadm_id = eli.hadm_id
ORDER BY
  adm.hadm_id NULLS FIRST