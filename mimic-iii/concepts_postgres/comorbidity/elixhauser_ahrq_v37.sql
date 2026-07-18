-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.elixhauser_ahrq_v37; CREATE TABLE mimiciii_derived.elixhauser_ahrq_v37 AS
/* This code uses the latest version of Elixhauser provided by AHRQ */
WITH eliflg AS (
  SELECT
    hadm_id,
    seq_num,
    icd9_code, /* note that these codes will seem incomplete at first */ /* for example, CHF is missing a lot of codes referenced in the literature (402.11, 402.91, etc) */ /* these codes are captured by hypertension flags instead */ /* later there are some complicated rules which confirm/reject those codes as chf */
    CASE
      WHEN icd9_code = '39891'
      THEN 1
      WHEN icd9_code BETWEEN '4280' AND '4289'
      THEN 1
    END AS chf, /* Congestive heart failure */ /* cardiac arrhythmias is removed in up to date versions */
    CASE
      WHEN icd9_code = '42610'
      THEN 1
      WHEN icd9_code = '42611'
      THEN 1
      WHEN icd9_code = '42613'
      THEN 1
      WHEN icd9_code BETWEEN '4262' AND '42653'
      THEN 1
      WHEN icd9_code BETWEEN '4266' AND '42689'
      THEN 1
      WHEN icd9_code = '4270'
      THEN 1
      WHEN icd9_code = '4272'
      THEN 1
      WHEN icd9_code = '42731'
      THEN 1
      WHEN icd9_code = '42760'
      THEN 1
      WHEN icd9_code = '4279'
      THEN 1
      WHEN icd9_code = '7850'
      THEN 1
      WHEN icd9_code BETWEEN 'V450' AND 'V4509'
      THEN 1
      WHEN icd9_code BETWEEN 'V533' AND 'V5339'
      THEN 1
    END AS arythm, /* Cardiac arrhythmias */
    CASE
      WHEN icd9_code BETWEEN '09320' AND '09324'
      THEN 1
      WHEN icd9_code BETWEEN '3940' AND '3971'
      THEN 1
      WHEN icd9_code = '3979'
      THEN 1
      WHEN icd9_code BETWEEN '4240' AND '42499'
      THEN 1
      WHEN icd9_code BETWEEN '7463' AND '7466'
      THEN 1
      WHEN icd9_code = 'V422'
      THEN 1
      WHEN icd9_code = 'V433'
      THEN 1
    END AS valve, /* Valvular disease */
    CASE
      WHEN icd9_code BETWEEN '41511' AND '41519'
      THEN 1
      WHEN icd9_code BETWEEN '4160' AND '4169'
      THEN 1
      WHEN icd9_code = '4179'
      THEN 1
    END AS pulmcirc, /* Pulmonary circulation disorder */
    CASE
      WHEN icd9_code BETWEEN '4400' AND '4409'
      THEN 1
      WHEN icd9_code BETWEEN '44100' AND '4419'
      THEN 1
      WHEN icd9_code BETWEEN '4420' AND '4429'
      THEN 1
      WHEN icd9_code BETWEEN '4431' AND '4439'
      THEN 1
      WHEN icd9_code BETWEEN '44421' AND '44422'
      THEN 1
      WHEN icd9_code = '4471'
      THEN 1
      WHEN icd9_code = '449'
      THEN 1
      WHEN icd9_code = '5571'
      THEN 1
      WHEN icd9_code = '5579'
      THEN 1
      WHEN icd9_code = 'V434'
      THEN 1
    END AS perivasc, /* Peripheral vascular disorder */
    CASE
      WHEN icd9_code = '4011'
      THEN 1
      WHEN icd9_code = '4019'
      THEN 1
      WHEN icd9_code BETWEEN '64200' AND '64204'
      THEN 1
    END AS htn, /* Hypertension, uncomplicated */
    CASE WHEN icd9_code = '4010' THEN 1 WHEN icd9_code = '4372' THEN 1 END AS htncx, /* Hypertension, complicated */ /* **************************************************************** */ /* The following are special, temporary formats used in the       */ /* creation of the hypertension complicated comorbidity when      */ /* overlapping with congestive heart failure or renal failure     */ /* occurs. These temporary formats are referenced in the program  */ /* called comoanaly2009.txt.                                      */ /* **************************************************************** */
    CASE WHEN icd9_code BETWEEN '64220' AND '64224' THEN 1 END AS htnpreg, /* Pre-existing hypertension complicating pregnancy */
    CASE
      WHEN icd9_code = '40200'
      THEN 1
      WHEN icd9_code = '40210'
      THEN 1
      WHEN icd9_code = '40290'
      THEN 1
      WHEN icd9_code = '40509'
      THEN 1
      WHEN icd9_code = '40519'
      THEN 1
      WHEN icd9_code = '40599'
      THEN 1
    END AS htnwochf, /* Hypertensive heart disease without heart failure */
    CASE
      WHEN icd9_code = '40201'
      THEN 1
      WHEN icd9_code = '40211'
      THEN 1
      WHEN icd9_code = '40291'
      THEN 1
    END AS htnwchf, /* Hypertensive heart disease with heart failure */
    CASE
      WHEN icd9_code = '40300'
      THEN 1
      WHEN icd9_code = '40310'
      THEN 1
      WHEN icd9_code = '40390'
      THEN 1
      WHEN icd9_code = '40501'
      THEN 1
      WHEN icd9_code = '40511'
      THEN 1
      WHEN icd9_code = '40591'
      THEN 1
      WHEN icd9_code BETWEEN '64210' AND '64214'
      THEN 1
    END AS hrenworf, /* Hypertensive renal disease without renal failure */
    CASE
      WHEN icd9_code = '40301'
      THEN 1
      WHEN icd9_code = '40311'
      THEN 1
      WHEN icd9_code = '40391'
      THEN 1
    END AS hrenwrf, /* Hypertensive renal disease with renal failure */
    CASE
      WHEN icd9_code = '40400'
      THEN 1
      WHEN icd9_code = '40410'
      THEN 1
      WHEN icd9_code = '40490'
      THEN 1
    END AS hhrwohrf, /* Hypertensive heart and renal disease without heart or renal failure */
    CASE
      WHEN icd9_code = '40401'
      THEN 1
      WHEN icd9_code = '40411'
      THEN 1
      WHEN icd9_code = '40491'
      THEN 1
    END AS hhrwchf, /* Hypertensive heart and renal disease with heart failure */
    CASE
      WHEN icd9_code = '40402'
      THEN 1
      WHEN icd9_code = '40412'
      THEN 1
      WHEN icd9_code = '40492'
      THEN 1
    END AS hhrwrf, /* Hypertensive heart and renal disease with renal failure */
    CASE
      WHEN icd9_code = '40403'
      THEN 1
      WHEN icd9_code = '40413'
      THEN 1
      WHEN icd9_code = '40493'
      THEN 1
    END AS hhrwhrf, /* Hypertensive heart and renal disease with heart and renal failure */
    CASE
      WHEN icd9_code BETWEEN '64270' AND '64274'
      THEN 1
      WHEN icd9_code BETWEEN '64290' AND '64294'
      THEN 1
    END AS ohtnpreg, /* Other hypertension in pregnancy */ /* ******************* End Temporary Formats ********************** */
    CASE
      WHEN icd9_code BETWEEN '3420' AND '3449'
      THEN 1
      WHEN icd9_code BETWEEN '43820' AND '43853'
      THEN 1
      WHEN icd9_code = '78072'
      THEN 1
    END AS para, /* Paralysis */
    CASE
      WHEN icd9_code BETWEEN '3300' AND '3319'
      THEN 1
      WHEN icd9_code = '3320'
      THEN 1
      WHEN icd9_code = '3334'
      THEN 1
      WHEN icd9_code = '3335'
      THEN 1
      WHEN icd9_code = '3337'
      THEN 1
      WHEN icd9_code IN ('33371', '33372', '33379', '33385', '33394')
      THEN 1
      WHEN icd9_code BETWEEN '3340' AND '3359'
      THEN 1
      WHEN icd9_code = '3380'
      THEN 1
      WHEN icd9_code = '340'
      THEN 1
      WHEN icd9_code BETWEEN '3411' AND '3419'
      THEN 1
      WHEN icd9_code BETWEEN '34500' AND '34511'
      THEN 1
      WHEN icd9_code BETWEEN '3452' AND '3453'
      THEN 1
      WHEN icd9_code BETWEEN '34540' AND '34591'
      THEN 1
      WHEN icd9_code BETWEEN '34700' AND '34701'
      THEN 1
      WHEN icd9_code BETWEEN '34710' AND '34711'
      THEN 1
      WHEN icd9_code = '3483'
      THEN 1 /* discontinued icd-9 */
      WHEN icd9_code BETWEEN '64940' AND '64944'
      THEN 1
      WHEN icd9_code = '7687'
      THEN 1
      WHEN icd9_code BETWEEN '76870' AND '76873'
      THEN 1
      WHEN icd9_code = '7803'
      THEN 1
      WHEN icd9_code = '78031'
      THEN 1
      WHEN icd9_code = '78032'
      THEN 1
      WHEN icd9_code = '78033'
      THEN 1
      WHEN icd9_code = '78039'
      THEN 1
      WHEN icd9_code = '78097'
      THEN 1
      WHEN icd9_code = '7843'
      THEN 1
    END AS neuro, /* Other neurological */
    CASE
      WHEN icd9_code BETWEEN '490' AND '4928'
      THEN 1
      WHEN icd9_code BETWEEN '49300' AND '49392'
      THEN 1
      WHEN icd9_code BETWEEN '494' AND '4941'
      THEN 1
      WHEN icd9_code BETWEEN '4950' AND '505'
      THEN 1
      WHEN icd9_code = '5064'
      THEN 1
    END AS chrnlung, /* Chronic pulmonary disease */
    CASE
      WHEN icd9_code BETWEEN '25000' AND '25033'
      THEN 1
      WHEN icd9_code BETWEEN '64800' AND '64804'
      THEN 1
      WHEN icd9_code BETWEEN '24900' AND '24931'
      THEN 1
    END AS dm, /* Diabetes w/o chronic complications */
    CASE
      WHEN icd9_code BETWEEN '25040' AND '25093'
      THEN 1
      WHEN icd9_code = '7751'
      THEN 1
      WHEN icd9_code BETWEEN '24940' AND '24991'
      THEN 1
    END AS dmcx, /* Diabetes w/ chronic complications */
    CASE
      WHEN icd9_code BETWEEN '243' AND '2442'
      THEN 1
      WHEN icd9_code = '2448'
      THEN 1
      WHEN icd9_code = '2449'
      THEN 1
    END AS hypothy, /* Hypothyroidism */
    CASE
      WHEN icd9_code = '585'
      THEN 1 /* discontinued code */
      WHEN icd9_code = '5853'
      THEN 1
      WHEN icd9_code = '5854'
      THEN 1
      WHEN icd9_code = '5855'
      THEN 1
      WHEN icd9_code = '5856'
      THEN 1
      WHEN icd9_code = '5859'
      THEN 1
      WHEN icd9_code = '586'
      THEN 1
      WHEN icd9_code = 'V420'
      THEN 1
      WHEN icd9_code = 'V451'
      THEN 1
      WHEN icd9_code BETWEEN 'V560' AND 'V5632'
      THEN 1
      WHEN icd9_code = 'V568'
      THEN 1
      WHEN icd9_code BETWEEN 'V4511' AND 'V4512'
      THEN 1
    END AS renlfail, /* Renal failure */
    CASE
      WHEN icd9_code = '07022'
      THEN 1
      WHEN icd9_code = '07023'
      THEN 1
      WHEN icd9_code = '07032'
      THEN 1
      WHEN icd9_code = '07033'
      THEN 1
      WHEN icd9_code = '07044'
      THEN 1
      WHEN icd9_code = '07054'
      THEN 1
      WHEN icd9_code = '4560'
      THEN 1
      WHEN icd9_code = '4561'
      THEN 1
      WHEN icd9_code = '45620'
      THEN 1
      WHEN icd9_code = '45621'
      THEN 1
      WHEN icd9_code = '5710'
      THEN 1
      WHEN icd9_code = '5712'
      THEN 1
      WHEN icd9_code = '5713'
      THEN 1
      WHEN icd9_code BETWEEN '57140' AND '57149'
      THEN 1
      WHEN icd9_code = '5715'
      THEN 1
      WHEN icd9_code = '5716'
      THEN 1
      WHEN icd9_code = '5718'
      THEN 1
      WHEN icd9_code = '5719'
      THEN 1
      WHEN icd9_code = '5723'
      THEN 1
      WHEN icd9_code = '5728'
      THEN 1
      WHEN icd9_code = '5735'
      THEN 1
      WHEN icd9_code = 'V427'
      THEN 1
    END AS liver, /* Liver disease */
    CASE
      WHEN icd9_code = '53141'
      THEN 1
      WHEN icd9_code = '53151'
      THEN 1
      WHEN icd9_code = '53161'
      THEN 1
      WHEN icd9_code = '53170'
      THEN 1
      WHEN icd9_code = '53171'
      THEN 1
      WHEN icd9_code = '53191'
      THEN 1
      WHEN icd9_code = '53241'
      THEN 1
      WHEN icd9_code = '53251'
      THEN 1
      WHEN icd9_code = '53261'
      THEN 1
      WHEN icd9_code = '53270'
      THEN 1
      WHEN icd9_code = '53271'
      THEN 1
      WHEN icd9_code = '53291'
      THEN 1
      WHEN icd9_code = '53341'
      THEN 1
      WHEN icd9_code = '53351'
      THEN 1
      WHEN icd9_code = '53361'
      THEN 1
      WHEN icd9_code = '53370'
      THEN 1
      WHEN icd9_code = '53371'
      THEN 1
      WHEN icd9_code = '53391'
      THEN 1
      WHEN icd9_code = '53441'
      THEN 1
      WHEN icd9_code = '53451'
      THEN 1
      WHEN icd9_code = '53461'
      THEN 1
      WHEN icd9_code = '53470'
      THEN 1
      WHEN icd9_code = '53471'
      THEN 1
      WHEN icd9_code = '53491'
      THEN 1
    END AS ulcer, /* Chronic Peptic ulcer disease (includes bleeding only if obstruction is also present) */
    CASE WHEN icd9_code BETWEEN '042' AND '0449' THEN 1 END AS aids, /* HIV and AIDS */
    CASE
      WHEN icd9_code BETWEEN '20000' AND '20238'
      THEN 1
      WHEN icd9_code BETWEEN '20250' AND '20301'
      THEN 1
      WHEN icd9_code = '2386'
      THEN 1
      WHEN icd9_code = '2733'
      THEN 1
      WHEN icd9_code BETWEEN '20302' AND '20382'
      THEN 1
    END AS lymph, /* Lymphoma */
    CASE
      WHEN icd9_code BETWEEN '1960' AND '1991'
      THEN 1
      WHEN icd9_code BETWEEN '20970' AND '20975'
      THEN 1
      WHEN icd9_code = '20979'
      THEN 1
      WHEN icd9_code = '78951'
      THEN 1
    END AS mets, /* Metastatic cancer */
    CASE
      WHEN icd9_code BETWEEN '1400' AND '1729'
      THEN 1
      WHEN icd9_code BETWEEN '1740' AND '1759'
      THEN 1
      WHEN icd9_code BETWEEN '179' AND '1958'
      THEN 1
      WHEN icd9_code BETWEEN '20900' AND '20924'
      THEN 1
      WHEN icd9_code BETWEEN '20925' AND '2093'
      THEN 1
      WHEN icd9_code BETWEEN '20930' AND '20936'
      THEN 1
      WHEN icd9_code BETWEEN '25801' AND '25803'
      THEN 1
    END AS tumor, /* Solid tumor without metastasis */
    CASE
      WHEN icd9_code = '7010'
      THEN 1
      WHEN icd9_code BETWEEN '7100' AND '7109'
      THEN 1
      WHEN icd9_code BETWEEN '7140' AND '7149'
      THEN 1
      WHEN icd9_code BETWEEN '7200' AND '7209'
      THEN 1
      WHEN icd9_code = '725'
      THEN 1
    END AS arth, /* Rheumatoid arthritis/collagen vascular diseases */
    CASE
      WHEN icd9_code BETWEEN '2860' AND '2869'
      THEN 1
      WHEN icd9_code = '2871'
      THEN 1
      WHEN icd9_code BETWEEN '2873' AND '2875'
      THEN 1
      WHEN icd9_code BETWEEN '64930' AND '64934'
      THEN 1
      WHEN icd9_code = '28984'
      THEN 1
    END AS coag, /* Coagulation deficiency */
    CASE
      WHEN icd9_code = '2780'
      THEN 1
      WHEN icd9_code = '27800'
      THEN 1
      WHEN icd9_code = '27801'
      THEN 1
      WHEN icd9_code = '27803'
      THEN 1
      WHEN icd9_code BETWEEN '64910' AND '64914'
      THEN 1
      WHEN icd9_code BETWEEN 'V8530' AND 'V8539'
      THEN 1
      WHEN icd9_code = 'V854'
      THEN 1 /* hierarchy used for AHRQ v3.6 and earlier */
      WHEN icd9_code BETWEEN 'V8541' AND 'V8545'
      THEN 1
      WHEN icd9_code = 'V8554'
      THEN 1
      WHEN icd9_code = '79391'
      THEN 1
    END AS obese, /* Obesity      */
    CASE
      WHEN icd9_code BETWEEN '260' AND '2639'
      THEN 1
      WHEN icd9_code BETWEEN '78321' AND '78322'
      THEN 1
    END AS wghtloss, /* Weight loss */
    CASE WHEN icd9_code BETWEEN '2760' AND '2769' THEN 1 END AS lytes, /* Fluid and electrolyte disorders - note:
                                      this comorbidity should be dropped when
                                      used with the AHRQ Patient Safety Indicators */
    CASE
      WHEN icd9_code = '2800'
      THEN 1
      WHEN icd9_code BETWEEN '64820' AND '64824'
      THEN 1
    END AS bldloss, /* Blood loss anemia */
    CASE
      WHEN icd9_code BETWEEN '2801' AND '2819'
      THEN 1
      WHEN icd9_code BETWEEN '28521' AND '28529'
      THEN 1
      WHEN icd9_code = '2859'
      THEN 1
    END AS anemdef, /* Deficiency anemias */
    CASE
      WHEN icd9_code BETWEEN '2910' AND '2913'
      THEN 1
      WHEN icd9_code = '2915'
      THEN 1
      WHEN icd9_code = '2918'
      THEN 1
      WHEN icd9_code = '29181'
      THEN 1
      WHEN icd9_code = '29182'
      THEN 1
      WHEN icd9_code = '29189'
      THEN 1
      WHEN icd9_code = '2919'
      THEN 1
      WHEN icd9_code BETWEEN '30300' AND '30393'
      THEN 1
      WHEN icd9_code BETWEEN '30500' AND '30503'
      THEN 1
    END AS alcohol, /* Alcohol abuse */
    CASE
      WHEN icd9_code = '2920'
      THEN 1
      WHEN icd9_code BETWEEN '29282' AND '29289'
      THEN 1
      WHEN icd9_code = '2929'
      THEN 1
      WHEN icd9_code BETWEEN '30400' AND '30493'
      THEN 1
      WHEN icd9_code BETWEEN '30520' AND '30593'
      THEN 1
      WHEN icd9_code BETWEEN '64830' AND '64834'
      THEN 1
    END AS drug, /* Drug abuse */
    CASE
      WHEN icd9_code BETWEEN '29500' AND '2989'
      THEN 1
      WHEN icd9_code = '29910'
      THEN 1
      WHEN icd9_code = '29911'
      THEN 1
    END AS psych, /* Psychoses */
    CASE
      WHEN icd9_code = '3004'
      THEN 1
      WHEN icd9_code = '30112'
      THEN 1
      WHEN icd9_code = '3090'
      THEN 1
      WHEN icd9_code = '3091'
      THEN 1
      WHEN icd9_code = '311'
      THEN 1
    END AS depress /* Depression */
  FROM mimiciii.diagnoses_icd AS icd
  WHERE
    seq_num = 1
), eligrp /* collapse the icd9_code specific flags into hadm_id specific flags */ /* this groups comorbidities together for a single patient admission */ AS (
  SELECT
    hadm_id,
    MAX(chf) AS chf,
    MAX(arythm) AS arythm,
    MAX(valve) AS valve,
    MAX(pulmcirc) AS pulmcirc,
    MAX(perivasc) AS perivasc,
    MAX(htn) AS htn,
    MAX(htncx) AS htncx,
    MAX(htnpreg) AS htnpreg,
    MAX(htnwochf) AS htnwochf,
    MAX(htnwchf) AS htnwchf,
    MAX(hrenworf) AS hrenworf,
    MAX(hrenwrf) AS hrenwrf,
    MAX(hhrwohrf) AS hhrwohrf,
    MAX(hhrwchf) AS hhrwchf,
    MAX(hhrwrf) AS hhrwrf,
    MAX(hhrwhrf) AS hhrwhrf,
    MAX(ohtnpreg) AS ohtnpreg,
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
), msdrg /* DRG FILTER -- */ AS (
  SELECT
    hadm_id, /* *** V29 MS-DRG Formats *** */ /* Cardiac */
    CASE
      WHEN d.drg_code BETWEEN 001 AND 002
      THEN 1
      WHEN d.drg_code BETWEEN 215 AND 238
      THEN 1
      WHEN d.drg_code BETWEEN 242 AND 252
      THEN 1
      WHEN d.drg_code BETWEEN 253 AND 254
      THEN 1
      WHEN d.drg_code BETWEEN 258 AND 262
      THEN 1
      WHEN d.drg_code BETWEEN 265 AND 267
      THEN 1
      WHEN d.drg_code BETWEEN 280 AND 293
      THEN 1
      WHEN d.drg_code BETWEEN 296 AND 298
      THEN 1
      WHEN d.drg_code BETWEEN 302 AND 303
      THEN 1
      WHEN d.drg_code BETWEEN 306 AND 313
      THEN 1
      ELSE 0
    END AS carddrg, /* Peripheral vascular */
    CASE WHEN d.drg_code BETWEEN 299 AND 301 THEN 1 ELSE 0 END AS peridrg, /* Renal */
    CASE
      WHEN d.drg_code = 652
      THEN 1
      WHEN d.drg_code BETWEEN 656 AND 661
      THEN 1
      WHEN d.drg_code BETWEEN 673 AND 675
      THEN 1
      WHEN d.drg_code BETWEEN 682 AND 700
      THEN 1
      ELSE 0
    END AS renaldrg, /* Nervous system */
    CASE
      WHEN d.drg_code BETWEEN 020 AND 042
      THEN 1
      WHEN d.drg_code BETWEEN 052 AND 103
      THEN 1
      ELSE 0
    END AS nervdrg, /* Cerebrovascular */
    CASE
      WHEN d.drg_code BETWEEN 020 AND 022
      THEN 1
      WHEN d.drg_code BETWEEN 034 AND 039
      THEN 1
      WHEN d.drg_code BETWEEN 064 AND 072
      THEN 1
      ELSE 0
    END AS ceredrg, /* COPD asthma */
    CASE
      WHEN d.drg_code BETWEEN 190 AND 192
      THEN 1
      WHEN d.drg_code BETWEEN 202 AND 203
      THEN 1
      ELSE 0
    END AS pulmdrg, /* Diabetes */
    CASE WHEN d.drg_code BETWEEN 637 AND 639 THEN 1 ELSE 0 END AS DIABDRG, /* Thyroid endocrine */
    CASE
      WHEN d.drg_code BETWEEN 625 AND 627
      THEN 1
      WHEN d.drg_code BETWEEN 643 AND 645
      THEN 1
      ELSE 0
    END AS hypodrg, /* Kidney transp, renal fail/dialysis */
    CASE
      WHEN d.drg_code = 652
      THEN 1
      WHEN d.drg_code BETWEEN 682 AND 685
      THEN 1
      ELSE 0
    END AS renfdrg, /* Liver */
    CASE
      WHEN d.drg_code BETWEEN 420 AND 425
      THEN 1
      WHEN d.drg_code BETWEEN 432 AND 434
      THEN 1
      WHEN d.drg_code BETWEEN 441 AND 446
      THEN 1
      ELSE 0
    END AS liverdrg, /* GI hemorrhage or ulcer */
    CASE WHEN d.drg_code BETWEEN 377 AND 384 THEN 1 ELSE 0 END AS ulcedrg, /* Human immunodeficiency virus */
    CASE
      WHEN d.drg_code BETWEEN 969 AND 970
      THEN 1
      WHEN d.drg_code BETWEEN 974 AND 977
      THEN 1
      ELSE 0
    END AS hivdrg, /* Leukemia/lymphoma */
    CASE
      WHEN d.drg_code BETWEEN 820 AND 830
      THEN 1
      WHEN d.drg_code BETWEEN 834 AND 849
      THEN 1
      ELSE 0
    END AS leukdrg, /* Cancer, lymphoma */
    CASE
      WHEN d.drg_code = 054
      THEN 1
      WHEN d.drg_code = 055
      THEN 1
      WHEN d.drg_code BETWEEN 146 AND 148
      THEN 1
      WHEN d.drg_code BETWEEN 180 AND 182
      THEN 1
      WHEN d.drg_code BETWEEN 374 AND 376
      THEN 1
      WHEN d.drg_code BETWEEN 435 AND 437
      THEN 1
      WHEN d.drg_code BETWEEN 542 AND 544
      THEN 1
      WHEN d.drg_code BETWEEN 582 AND 585
      THEN 1
      WHEN d.drg_code BETWEEN 597 AND 599
      THEN 1
      WHEN d.drg_code BETWEEN 656 AND 658
      THEN 1
      WHEN d.drg_code BETWEEN 686 AND 688
      THEN 1
      WHEN d.drg_code BETWEEN 715 AND 716
      THEN 1
      WHEN d.drg_code BETWEEN 722 AND 724
      THEN 1
      WHEN d.drg_code BETWEEN 736 AND 741
      THEN 1
      WHEN d.drg_code BETWEEN 754 AND 756
      THEN 1
      WHEN d.drg_code BETWEEN 826 AND 830
      THEN 1
      WHEN d.drg_code BETWEEN 843 AND 849
      THEN 1
      ELSE 0
    END AS cancdrg, /* Connective tissue */
    CASE WHEN d.drg_code BETWEEN 545 AND 547 THEN 1 ELSE 0 END AS arthdrg, /* Nutrition/metabolic */
    CASE WHEN d.drg_code BETWEEN 640 AND 641 THEN 1 ELSE 0 END AS nutrdrg, /* Anemia */
    CASE WHEN d.drg_code BETWEEN 808 AND 812 THEN 1 ELSE 0 END AS anemdrg, /* Alcohol drug */
    CASE WHEN d.drg_code BETWEEN 894 AND 897 THEN 1 ELSE 0 END AS alcdrg, /* Coagulation disorders */
    CASE WHEN d.drg_code = 813 THEN 1 ELSE 0 END AS coagdrg, /* Hypertensive Complicated  */
    CASE
      WHEN d.drg_code = 077
      THEN 1
      WHEN d.drg_code = 078
      THEN 1
      WHEN d.drg_code = 304
      THEN 1
      ELSE 0
    END AS htncxdrg, /* Hypertensive Uncomplicated  */
    CASE WHEN d.drg_code = 079 THEN 1 WHEN d.drg_code = 305 THEN 1 ELSE 0 END AS htndrg, /* Psychoses */
    CASE WHEN d.drg_code = 885 THEN 1 ELSE 0 END AS psydrg, /* Obesity */
    CASE WHEN d.drg_code BETWEEN 619 AND 621 THEN 1 ELSE 0 END AS obesedrg, /* Depressive Neuroses */
    CASE WHEN d.drg_code = 881 THEN 1 ELSE 0 END AS deprsdrg
  FROM (
    SELECT
      hadm_id,
      drg_type,
      CAST(drg_code AS DECIMAL(38, 9)) AS drg_code
    FROM mimiciii.drgcodes
    WHERE
      drg_type = 'MS'
  ) AS d
), hcfadrg AS (
  SELECT
    hadm_id, /* * V24 DRG Formats  * */ /* Cardiac */
    CASE
      WHEN d.drg_code BETWEEN 103 AND 112
      THEN 1
      WHEN d.drg_code BETWEEN 115 AND 118
      THEN 1
      WHEN d.drg_code BETWEEN 121 AND 127
      THEN 1
      WHEN d.drg_code = 129
      THEN 1
      WHEN d.drg_code = 132
      THEN 1
      WHEN d.drg_code = 133
      THEN 1
      WHEN d.drg_code BETWEEN 135 AND 143
      THEN 1
      WHEN d.drg_code BETWEEN 514 AND 518
      THEN 1
      WHEN d.drg_code BETWEEN 525 AND 527
      THEN 1
      WHEN d.drg_code BETWEEN 535 AND 536
      THEN 1
      WHEN d.drg_code BETWEEN 547 AND 550
      THEN 1
      WHEN d.drg_code BETWEEN 551 AND 558
      THEN 1
      ELSE 0
    END AS carddrg, /* Peripheral vascular */
    CASE WHEN d.drg_code = 130 THEN 1 WHEN d.drg_code = 131 THEN 1 ELSE 0 END AS peridrg, /* Renal */
    CASE
      WHEN d.drg_code BETWEEN 302 AND 305
      THEN 1
      WHEN d.drg_code BETWEEN 315 AND 333
      THEN 1
      ELSE 0
    END AS renaldrg, /* Nervous system */
    CASE
      WHEN d.drg_code BETWEEN 1 AND 35
      THEN 1
      WHEN d.drg_code = 524
      THEN 1
      WHEN d.drg_code BETWEEN 528 AND 534
      THEN 1
      WHEN d.drg_code = 543
      THEN 1
      WHEN d.drg_code BETWEEN 559 AND 564
      THEN 1
      WHEN d.drg_code = 577
      THEN 1
      ELSE 0
    END AS nervdrg, /* Cerebrovascular */
    CASE
      WHEN d.drg_code = 5
      THEN 1
      WHEN d.drg_code BETWEEN 14 AND 17
      THEN 1
      WHEN d.drg_code = 524
      THEN 1
      WHEN d.drg_code = 528
      THEN 1
      WHEN d.drg_code BETWEEN 533 AND 534
      THEN 1
      WHEN d.drg_code = 577
      THEN 1
      ELSE 0
    END AS ceredrg, /* COPD asthma */
    CASE WHEN d.drg_code = 88 THEN 1 WHEN d.drg_code BETWEEN 96 AND 98 THEN 1 ELSE 0 END AS pulmdrg, /* Diabetes */
    CASE WHEN d.drg_code = 294 THEN 1 WHEN d.drg_code = 295 THEN 1 ELSE 0 END AS diabdrg, /* Thyroid endocrine */
    CASE
      WHEN d.drg_code = 290
      THEN 1
      WHEN d.drg_code = 300
      THEN 1
      WHEN d.drg_code = 301
      THEN 1
      ELSE 0
    END AS hypodrg, /* Kidney transp, renal fail/dialysis */
    CASE
      WHEN d.drg_code = 302
      THEN 1
      WHEN d.drg_code = 316
      THEN 1
      WHEN d.drg_code = 317
      THEN 1
      ELSE 0
    END AS renfdrg, /* Liver */
    CASE
      WHEN d.drg_code BETWEEN 199 AND 202
      THEN 1
      WHEN d.drg_code BETWEEN 205 AND 208
      THEN 1
      ELSE 0
    END AS liverdrg, /* GI hemorrhage or ulcer */
    CASE WHEN d.drg_code BETWEEN 174 AND 178 THEN 1 ELSE 0 END AS ulcedrg, /* Human immunodeficiency virus */
    CASE
      WHEN d.drg_code = 488
      THEN 1
      WHEN d.drg_code = 489
      THEN 1
      WHEN d.drg_code = 490
      THEN 1
      ELSE 0
    END AS hivdrg, /* Leukemia/lymphoma */
    CASE
      WHEN d.drg_code BETWEEN 400 AND 414
      THEN 1
      WHEN d.drg_code = 473
      THEN 1
      WHEN d.drg_code = 492
      THEN 1
      WHEN d.drg_code BETWEEN 539 AND 540
      THEN 1
      ELSE 0
    END AS leukdrg, /* Cancer, lymphoma */
    CASE
      WHEN d.drg_code = 10
      THEN 1
      WHEN d.drg_code = 11
      THEN 1
      WHEN d.drg_code = 64
      THEN 1
      WHEN d.drg_code = 82
      THEN 1
      WHEN d.drg_code = 172
      THEN 1
      WHEN d.drg_code = 173
      THEN 1
      WHEN d.drg_code = 199
      THEN 1
      WHEN d.drg_code = 203
      THEN 1
      WHEN d.drg_code = 239
      THEN 1
      WHEN d.drg_code BETWEEN 257 AND 260
      THEN 1
      WHEN d.drg_code = 274
      THEN 1
      WHEN d.drg_code = 275
      THEN 1
      WHEN d.drg_code = 303
      THEN 1
      WHEN d.drg_code = 318
      THEN 1
      WHEN d.drg_code = 319
      THEN 1
      WHEN d.drg_code = 338
      THEN 1
      WHEN d.drg_code = 344
      THEN 1
      WHEN d.drg_code = 346
      THEN 1
      WHEN d.drg_code = 347
      THEN 1
      WHEN d.drg_code = 354
      THEN 1
      WHEN d.drg_code = 355
      THEN 1
      WHEN d.drg_code = 357
      THEN 1
      WHEN d.drg_code = 363
      THEN 1
      WHEN d.drg_code = 366
      THEN 1
      WHEN d.drg_code = 367
      THEN 1
      WHEN d.drg_code BETWEEN 406 AND 414
      THEN 1
      ELSE 0
    END AS cancdrg, /* Connective tissue */
    CASE WHEN d.drg_code = 240 THEN 1 WHEN d.drg_code = 241 THEN 1 ELSE 0 END AS arthdrg, /* Nutrition/metabolic */
    CASE WHEN d.drg_code BETWEEN 296 AND 298 THEN 1 ELSE 0 END AS nutrdrg, /* Anemia */
    CASE
      WHEN d.drg_code = 395
      THEN 1
      WHEN d.drg_code = 396
      THEN 1
      WHEN d.drg_code = 574
      THEN 1
      ELSE 0
    END AS anemdrg, /* Alcohol drug */
    CASE
      WHEN d.drg_code BETWEEN 433 AND 437
      THEN 1
      WHEN d.drg_code BETWEEN 521 AND 523
      THEN 1
      ELSE 0
    END AS alcdrg, /* Coagulation disorders */
    CASE WHEN d.drg_code = 397 THEN 1 ELSE 0 END AS coagdrg, /* Hypertensive Complicated */
    CASE WHEN d.drg_code = 22 THEN 1 WHEN d.drg_code = 134 THEN 1 ELSE 0 END AS htncxdrg, /* Hypertensive Uncomplicated */
    CASE WHEN d.drg_code = 134 THEN 1 ELSE 0 END AS htndrg, /* Psychoses */
    CASE WHEN d.drg_code = 430 THEN 1 ELSE 0 END AS psydrg, /* Obesity */
    CASE WHEN d.drg_code = 288 THEN 1 ELSE 0 END AS obesedrg, /* Depressive Neuroses */
    CASE WHEN d.drg_code = 426 THEN 1 ELSE 0 END AS deprsdrg
  FROM (
    SELECT
      hadm_id,
      drg_type,
      CAST(drg_code AS DECIMAL(38, 9)) AS drg_code
    FROM mimiciii.drgcodes
    WHERE
      drg_type = 'HCFA'
  ) AS d
), drggrp /* merge DRG groups together */ AS (
  SELECT
    hadm_id,
    MAX(carddrg) AS carddrg,
    MAX(peridrg) AS peridrg,
    MAX(renaldrg) AS renaldrg,
    MAX(nervdrg) AS nervdrg,
    MAX(ceredrg) AS ceredrg,
    MAX(pulmdrg) AS pulmdrg,
    MAX(diabdrg) AS diabdrg,
    MAX(hypodrg) AS hypodrg,
    MAX(renfdrg) AS renfdrg,
    MAX(liverdrg) AS liverdrg,
    MAX(ulcedrg) AS ulcedrg,
    MAX(hivdrg) AS hivdrg,
    MAX(leukdrg) AS leukdrg,
    MAX(cancdrg) AS cancdrg,
    MAX(arthdrg) AS arthdrg,
    MAX(nutrdrg) AS nutrdrg,
    MAX(anemdrg) AS anemdrg,
    MAX(alcdrg) AS alcdrg,
    MAX(coagdrg) AS coagdrg,
    MAX(htncxdrg) AS htncxdrg,
    MAX(htndrg) AS htndrg,
    MAX(psydrg) AS psydrg,
    MAX(obesedrg) AS obesedrg,
    MAX(deprsdrg) AS deprsdrg
  FROM (
    SELECT
      d1.*
    FROM msdrg AS d1
    UNION
    SELECT
      d1.*
    FROM hcfadrg AS d1
  ) AS d
  GROUP BY
    d.hadm_id
)
/* now merge these flags together to define elixhauser */ /* most are straightforward.. but hypertension flags are a bit more complicated */
SELECT
  adm.subject_id,
  adm.hadm_id,
  CASE
    WHEN carddrg = 1
    THEN 0 /* DRG filter */
    WHEN chf = 1
    THEN 1
    WHEN htnwchf = 1
    THEN 1
    WHEN hhrwchf = 1
    THEN 1
    WHEN hhrwhrf = 1
    THEN 1
    ELSE 0
  END AS congestive_heart_failure,
  CASE WHEN carddrg = 1 THEN 0 /* DRG filter */ WHEN arythm = 1 THEN 1 ELSE 0 END AS cardiac_arrhythmias,
  CASE WHEN carddrg = 1 THEN 0 WHEN valve = 1 THEN 1 ELSE 0 END AS valvular_disease,
  CASE WHEN carddrg = 1 OR pulmdrg = 1 THEN 0 WHEN pulmcirc = 1 THEN 1 ELSE 0 END AS pulmonary_circulation,
  CASE WHEN peridrg = 1 THEN 0 WHEN perivasc = 1 THEN 1 ELSE 0 END AS peripheral_vascular, /* we combine 'htn' and 'htncx' into 'HYPERTENSION' */ /* note 'htn' (hypertension) is only 1 if 'htncx' (complicated hypertension) is 0 */ /* also if htncxdrg = 1, then htndrg = 1 */ /* In the original Sas code, it appears that: */ /*  HTN can be 1 */ /*  HTNCX is set to 0 by DRGs */ /*  but HTN_C is still 1, because HTN is 1 */ /* so we have to do this complex addition. */
  CASE
    WHEN (
      CASE WHEN htndrg = 0 THEN 0 WHEN htn = 1 THEN 1 ELSE 0 END /* first hypertension */
    ) + (
      CASE
        WHEN htncx = 1 AND htncxdrg = 1
        THEN 0
        WHEN htnpreg = 1 AND htncxdrg = 1
        THEN 0
        WHEN htnwochf = 1 AND (
          htncxdrg = 1 OR carddrg = 1
        )
        THEN 0
        WHEN htnwchf = 1 AND htncxdrg = 1
        THEN 0
        WHEN htnwchf = 1 AND carddrg = 1
        THEN 0
        WHEN hrenworf = 1 AND (
          htncxdrg = 1 OR renaldrg = 1
        )
        THEN 0
        WHEN hrenwrf = 1 AND htncxdrg = 1
        THEN 0
        WHEN hrenwrf = 1 AND renaldrg = 1
        THEN 0
        WHEN hhrwohrf = 1 AND (
          htncxdrg = 1 OR carddrg = 1 OR renaldrg = 1
        )
        THEN 0
        WHEN hhrwchf = 1 AND (
          htncxdrg = 1 OR carddrg = 1 OR renaldrg = 1
        )
        THEN 0
        WHEN hhrwrf = 1 AND (
          htncxdrg = 1 OR carddrg = 1 OR renaldrg = 1
        )
        THEN 0
        WHEN hhrwhrf = 1 AND (
          htncxdrg = 1 OR carddrg = 1 OR renaldrg = 1
        )
        THEN 0
        WHEN ohtnpreg = 1 AND (
          htncxdrg = 1 OR carddrg = 1 OR renaldrg = 1
        )
        THEN 0
        WHEN htncx = 1
        THEN 1
        WHEN htnpreg = 1
        THEN 1
        WHEN htnwochf = 1
        THEN 1
        WHEN htnwchf = 1
        THEN 1
        WHEN hrenworf = 1
        THEN 1
        WHEN hrenwrf = 1
        THEN 1
        WHEN hhrwohrf = 1
        THEN 1
        WHEN hhrwchf = 1
        THEN 1
        WHEN hhrwrf = 1
        THEN 1
        WHEN hhrwhrf = 1
        THEN 1
        WHEN ohtnpreg = 1
        THEN 1
        ELSE 0
      END /* next complicated hypertension */
    ) > 0
    THEN 1
    ELSE 0
  END AS hypertension,
  CASE WHEN ceredrg = 1 THEN 0 WHEN para = 1 THEN 1 ELSE 0 END AS paralysis,
  CASE WHEN nervdrg = 1 THEN 0 WHEN neuro = 1 THEN 1 ELSE 0 END AS other_neurological,
  CASE WHEN pulmdrg = 1 THEN 0 WHEN chrnlung = 1 THEN 1 ELSE 0 END AS chronic_pulmonary,
  CASE WHEN diabdrg = 1 THEN 0 WHEN dmcx = 1 THEN 0 WHEN dm = 1 THEN 1 ELSE 0 END AS diabetes_uncomplicated,
  CASE WHEN diabdrg = 1 THEN 0 WHEN dmcx = 1 THEN 1 ELSE 0 END AS diabetes_complicated,
  CASE WHEN hypodrg = 1 THEN 0 WHEN hypothy = 1 THEN 1 ELSE 0 END AS hypothyroidism,
  CASE
    WHEN renaldrg = 1
    THEN 0
    WHEN renlfail = 1
    THEN 1
    WHEN hrenwrf = 1
    THEN 1
    WHEN hhrwrf = 1
    THEN 1
    WHEN hhrwhrf = 1
    THEN 1
    ELSE 0
  END AS renal_failure,
  CASE WHEN liverdrg = 1 THEN 0 WHEN liver = 1 THEN 1 ELSE 0 END AS liver_disease,
  CASE WHEN ulcedrg = 1 THEN 0 WHEN ulcer = 1 THEN 1 ELSE 0 END AS peptic_ulcer,
  CASE WHEN hivdrg = 1 THEN 0 WHEN aids = 1 THEN 1 ELSE 0 END AS aids,
  CASE WHEN leukdrg = 1 THEN 0 WHEN lymph = 1 THEN 1 ELSE 0 END AS lymphoma,
  CASE WHEN cancdrg = 1 THEN 0 WHEN mets = 1 THEN 1 ELSE 0 END AS metastatic_cancer,
  CASE WHEN cancdrg = 1 THEN 0 WHEN mets = 1 THEN 0 WHEN tumor = 1 THEN 1 ELSE 0 END AS solid_tumor,
  CASE WHEN arthdrg = 1 THEN 0 WHEN arth = 1 THEN 1 ELSE 0 END AS rheumatoid_arthritis,
  CASE WHEN coagdrg = 1 THEN 0 WHEN coag = 1 THEN 1 ELSE 0 END AS coagulopathy,
  CASE WHEN nutrdrg = 1 OR obesedrg = 1 THEN 0 WHEN obese = 1 THEN 1 ELSE 0 END AS obesity,
  CASE WHEN nutrdrg = 1 THEN 0 WHEN wghtloss = 1 THEN 1 ELSE 0 END AS weight_loss,
  CASE WHEN nutrdrg = 1 THEN 0 WHEN lytes = 1 THEN 1 ELSE 0 END AS fluid_electrolyte,
  CASE WHEN anemdrg = 1 THEN 0 WHEN bldloss = 1 THEN 1 ELSE 0 END AS blood_loss_anemia,
  CASE WHEN anemdrg = 1 THEN 0 WHEN anemdef = 1 THEN 1 ELSE 0 END AS deficiency_anemias,
  CASE WHEN alcdrg = 1 THEN 0 WHEN alcohol = 1 THEN 1 ELSE 0 END AS alcohol_abuse,
  CASE WHEN alcdrg = 1 THEN 0 WHEN drug = 1 THEN 1 ELSE 0 END AS drug_abuse,
  CASE WHEN psydrg = 1 THEN 0 WHEN psych = 1 THEN 1 ELSE 0 END AS psychoses,
  CASE WHEN deprsdrg = 1 THEN 0 WHEN depress = 1 THEN 1 ELSE 0 END AS depression
FROM mimiciii.admissions AS adm
LEFT JOIN eligrp AS eli
  ON adm.hadm_id = eli.hadm_id
LEFT JOIN drggrp AS d
  ON adm.hadm_id = d.hadm_id
ORDER BY
  adm.hadm_id NULLS FIRST