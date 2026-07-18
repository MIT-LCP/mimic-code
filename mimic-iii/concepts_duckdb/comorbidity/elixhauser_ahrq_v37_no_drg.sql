-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.elixhauser_ahrq_v37_no_drg; CREATE TABLE mimiciii_derived.elixhauser_ahrq_v37_no_drg AS
WITH eliflg AS (
  SELECT
    hadm_id,
    seq_num,
    icd9_code,
    CASE
      WHEN icd9_code = '39891'
      THEN 1
      WHEN icd9_code BETWEEN '4280' AND '4289'
      THEN 1
    END AS chf,
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
    END AS arythm,
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
    END AS valve,
    CASE
      WHEN icd9_code BETWEEN '41511' AND '41519'
      THEN 1
      WHEN icd9_code BETWEEN '4160' AND '4169'
      THEN 1
      WHEN icd9_code = '4179'
      THEN 1
    END AS pulmcirc,
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
    END AS perivasc,
    CASE
      WHEN icd9_code = '4011'
      THEN 1
      WHEN icd9_code = '4019'
      THEN 1
      WHEN icd9_code BETWEEN '64200' AND '64204'
      THEN 1
    END AS htn,
    CASE WHEN icd9_code = '4010' THEN 1 WHEN icd9_code = '4372' THEN 1 END AS htncx,
    CASE WHEN icd9_code BETWEEN '64220' AND '64224' THEN 1 END AS htnpreg,
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
    END AS htnwochf,
    CASE
      WHEN icd9_code = '40201'
      THEN 1
      WHEN icd9_code = '40211'
      THEN 1
      WHEN icd9_code = '40291'
      THEN 1
    END AS htnwchf,
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
    END AS hrenworf,
    CASE
      WHEN icd9_code = '40301'
      THEN 1
      WHEN icd9_code = '40311'
      THEN 1
      WHEN icd9_code = '40391'
      THEN 1
    END AS hrenwrf,
    CASE
      WHEN icd9_code = '40400'
      THEN 1
      WHEN icd9_code = '40410'
      THEN 1
      WHEN icd9_code = '40490'
      THEN 1
    END AS hhrwohrf,
    CASE
      WHEN icd9_code = '40401'
      THEN 1
      WHEN icd9_code = '40411'
      THEN 1
      WHEN icd9_code = '40491'
      THEN 1
    END AS hhrwchf,
    CASE
      WHEN icd9_code = '40402'
      THEN 1
      WHEN icd9_code = '40412'
      THEN 1
      WHEN icd9_code = '40492'
      THEN 1
    END AS hhrwrf,
    CASE
      WHEN icd9_code = '40403'
      THEN 1
      WHEN icd9_code = '40413'
      THEN 1
      WHEN icd9_code = '40493'
      THEN 1
    END AS hhrwhrf,
    CASE
      WHEN icd9_code BETWEEN '64270' AND '64274'
      THEN 1
      WHEN icd9_code BETWEEN '64290' AND '64294'
      THEN 1
    END AS ohtnpreg,
    CASE
      WHEN icd9_code BETWEEN '3420' AND '3449'
      THEN 1
      WHEN icd9_code BETWEEN '43820' AND '43853'
      THEN 1
      WHEN icd9_code = '78072'
      THEN 1
    END AS para,
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
      THEN 1
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
    END AS neuro,
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
    END AS chrnlung,
    CASE
      WHEN icd9_code BETWEEN '25000' AND '25033'
      THEN 1
      WHEN icd9_code BETWEEN '64800' AND '64804'
      THEN 1
      WHEN icd9_code BETWEEN '24900' AND '24931'
      THEN 1
    END AS dm,
    CASE
      WHEN icd9_code BETWEEN '25040' AND '25093'
      THEN 1
      WHEN icd9_code = '7751'
      THEN 1
      WHEN icd9_code BETWEEN '24940' AND '24991'
      THEN 1
    END AS dmcx,
    CASE
      WHEN icd9_code BETWEEN '243' AND '2442'
      THEN 1
      WHEN icd9_code = '2448'
      THEN 1
      WHEN icd9_code = '2449'
      THEN 1
    END AS hypothy,
    CASE
      WHEN icd9_code = '585'
      THEN 1
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
    END AS renlfail,
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
    END AS liver,
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
    END AS ulcer,
    CASE WHEN icd9_code BETWEEN '042' AND '0449' THEN 1 END AS aids,
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
    END AS lymph,
    CASE
      WHEN icd9_code BETWEEN '1960' AND '1991'
      THEN 1
      WHEN icd9_code BETWEEN '20970' AND '20975'
      THEN 1
      WHEN icd9_code = '20979'
      THEN 1
      WHEN icd9_code = '78951'
      THEN 1
    END AS mets,
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
    END AS tumor,
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
    END AS arth,
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
    END AS coag,
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
      THEN 1
      WHEN icd9_code BETWEEN 'V8541' AND 'V8545'
      THEN 1
      WHEN icd9_code = 'V8554'
      THEN 1
      WHEN icd9_code = '79391'
      THEN 1
    END AS obese,
    CASE
      WHEN icd9_code BETWEEN '260' AND '2639'
      THEN 1
      WHEN icd9_code BETWEEN '78321' AND '78322'
      THEN 1
    END AS wghtloss,
    CASE WHEN icd9_code BETWEEN '2760' AND '2769' THEN 1 END AS lytes,
    CASE
      WHEN icd9_code = '2800'
      THEN 1
      WHEN icd9_code BETWEEN '64820' AND '64824'
      THEN 1
    END AS bldloss,
    CASE
      WHEN icd9_code BETWEEN '2801' AND '2819'
      THEN 1
      WHEN icd9_code BETWEEN '28521' AND '28529'
      THEN 1
      WHEN icd9_code = '2859'
      THEN 1
    END AS anemdef,
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
    END AS alcohol,
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
    END AS drug,
    CASE
      WHEN icd9_code BETWEEN '29500' AND '2989'
      THEN 1
      WHEN icd9_code = '29910'
      THEN 1
      WHEN icd9_code = '29911'
      THEN 1
    END AS psych,
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
    END AS depress
  FROM mimiciii.diagnoses_icd AS icd
  WHERE
    seq_num = 1
), eligrp AS (
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
)
SELECT
  adm.subject_id,
  adm.hadm_id,
  CASE
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
  CASE WHEN arythm = 1 THEN 1 ELSE 0 END AS cardiac_arrhythmias,
  CASE WHEN valve = 1 THEN 1 ELSE 0 END AS valvular_disease,
  CASE WHEN pulmcirc = 1 THEN 1 ELSE 0 END AS pulmonary_circulation,
  CASE WHEN perivasc = 1 THEN 1 ELSE 0 END AS peripheral_vascular,
  CASE
    WHEN htn = 1
    THEN 1
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
  END AS hypertension,
  CASE WHEN para = 1 THEN 1 ELSE 0 END AS paralysis,
  CASE WHEN neuro = 1 THEN 1 ELSE 0 END AS other_neurological,
  CASE WHEN chrnlung = 1 THEN 1 ELSE 0 END AS chronic_pulmonary,
  CASE WHEN dmcx = 1 THEN 0 WHEN dm = 1 THEN 1 ELSE 0 END AS diabetes_uncomplicated,
  CASE WHEN dmcx = 1 THEN 1 ELSE 0 END AS diabetes_complicated,
  CASE WHEN hypothy = 1 THEN 1 ELSE 0 END AS hypothyroidism,
  CASE
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
  CASE WHEN liver = 1 THEN 1 ELSE 0 END AS liver_disease,
  CASE WHEN ulcer = 1 THEN 1 ELSE 0 END AS peptic_ulcer,
  CASE WHEN aids = 1 THEN 1 ELSE 0 END AS aids,
  CASE WHEN lymph = 1 THEN 1 ELSE 0 END AS lymphoma,
  CASE WHEN mets = 1 THEN 1 ELSE 0 END AS metastatic_cancer,
  CASE WHEN mets = 1 THEN 0 WHEN tumor = 1 THEN 1 ELSE 0 END AS solid_tumor,
  CASE WHEN arth = 1 THEN 1 ELSE 0 END AS rheumatoid_arthritis,
  CASE WHEN coag = 1 THEN 1 ELSE 0 END AS coagulopathy,
  CASE WHEN obese = 1 THEN 1 ELSE 0 END AS obesity,
  CASE WHEN wghtloss = 1 THEN 1 ELSE 0 END AS weight_loss,
  CASE WHEN lytes = 1 THEN 1 ELSE 0 END AS fluid_electrolyte,
  CASE WHEN bldloss = 1 THEN 1 ELSE 0 END AS blood_loss_anemia,
  CASE WHEN anemdef = 1 THEN 1 ELSE 0 END AS deficiency_anemias,
  CASE WHEN alcohol = 1 THEN 1 ELSE 0 END AS alcohol_abuse,
  CASE WHEN drug = 1 THEN 1 ELSE 0 END AS drug_abuse,
  CASE WHEN psych = 1 THEN 1 ELSE 0 END AS psychoses,
  CASE WHEN depress = 1 THEN 1 ELSE 0 END AS depression
FROM mimiciii.admissions AS adm
LEFT JOIN eligrp AS eli
  ON adm.hadm_id = eli.hadm_id
ORDER BY
  adm.hadm_id NULLS FIRST