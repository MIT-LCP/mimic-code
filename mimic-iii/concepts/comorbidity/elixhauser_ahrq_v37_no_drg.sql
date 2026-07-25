-- This code uses the latest version of Elixhauser provided by AHRQ
-- However, it does *not* filter based on diagnosis related groups (DRGs)
-- As such, "comorbidities" identified are more likely to be associated with the primary reason for their hospital stay

-- The code:
--  removes "primary" ICD9_CODE (seq_num != 1)
--  uses AHRQ published rules to define comorbidities
with
eliflg as
(
select hadm_id, seq_num, icd9_code
-- note that these codes will seem incomplete at first
-- for example, CHF is missing a lot of codes referenced in the literature (402.11, 402.91, etc)
-- these codes are captured by hypertension flags instead
-- later there are some complicated rules which confirm/reject those codes as chf
, CASE
  when icd9_code = '39891' then 1
  when icd9_code between '4280' and '4289' then 1
		end as chf       /* Congestive heart failure */

-- cardiac arrhythmias is removed in up to date versions
, case
    when icd9_code = '42610' then 1
    when icd9_code = '42611' then 1
    when icd9_code = '42613' then 1
    when icd9_code between '4262' and '42653' then 1
    when icd9_code between '4266' and '42689' then 1
    when icd9_code = '4270' then 1
    when icd9_code = '4272' then 1
    when icd9_code = '42731' then 1
    when icd9_code = '42760' then 1
    when icd9_code = '4279' then 1
    when icd9_code = '7850' then 1
    when icd9_code between 'V450' and 'V4509' then 1
    when icd9_code between 'V533' and 'V5339' then 1
  end as arythm /* Cardiac arrhythmias */

, CASE
  when icd9_code between '09320' and '09324' then 1
  when icd9_code between '3940' and '3971' then 1
  when icd9_code = '3979' then 1
  when icd9_code between '4240' and '42499' then 1
  when icd9_code between '7463' and '7466' then 1
  when icd9_code = 'V422' then 1
  when icd9_code = 'V433' then 1
		end as valve     /* Valvular disease */

, CASE
  when icd9_code between '41511' and '41519' then 1
  when icd9_code between '4160' and '4169' then 1
  when icd9_code = '4179' then 1
		end as pulmcirc  /* Pulmonary circulation disorder */

, CASE
  when icd9_code between '4400' and '4409' then 1
  when icd9_code between '44100' and '4419' then 1
  when icd9_code between '4420' and '4429' then 1
  when icd9_code between '4431' and '4439' then 1
  when icd9_code between '44421' and '44422' then 1
  when icd9_code = '4471' then 1
  when icd9_code = '449' then 1
  when icd9_code = '5571' then 1
  when icd9_code = '5579' then 1
  when icd9_code = 'V434' then 1
		end as perivasc  /* Peripheral vascular disorder */

, CASE
  when icd9_code = '4011' then 1
  when icd9_code = '4019' then 1
  when icd9_code between '64200' and '64204' then 1
		end as htn       /* Hypertension, uncomplicated */

, CASE
  when icd9_code = '4010' then 1
  when icd9_code = '4372' then 1
		end as htncx     /* Hypertension, complicated */


      /******************************************************************/
      /* The following are special, temporary formats used in the       */
      /* creation of the hypertension complicated comorbidity when      */
      /* overlapping with congestive heart failure or renal failure     */
      /* occurs. These temporary formats are referenced in the program  */
      /* called comoanaly2009.txt.                                      */
      /******************************************************************/
, CASE
  when icd9_code between '64220' and '64224' then 1
		end as htnpreg   /* Pre-existing hypertension complicating pregnancy */

, CASE
  when icd9_code = '40200' then 1
  when icd9_code = '40210' then 1
  when icd9_code = '40290' then 1
  when icd9_code = '40509' then 1
  when icd9_code = '40519' then 1
  when icd9_code = '40599'         then 1
		end as htnwochf  /* Hypertensive heart disease without heart failure */

, CASE
  when icd9_code = '40201' then 1
  when icd9_code = '40211' then 1
  when icd9_code = '40291'         then 1
		end as htnwchf   /* Hypertensive heart disease with heart failure */

, CASE
  when icd9_code = '40300' then 1
  when icd9_code = '40310' then 1
  when icd9_code = '40390' then 1
  when icd9_code = '40501' then 1
  when icd9_code = '40511' then 1
  when icd9_code = '40591' then 1
  when icd9_code between '64210' and '64214' then 1
		end as hrenworf  /* Hypertensive renal disease without renal failure */

, CASE
  when icd9_code = '40301' then 1
  when icd9_code = '40311' then 1
  when icd9_code = '40391'         then 1
		end as hrenwrf   /* Hypertensive renal disease with renal failure */

, CASE
  when icd9_code = '40400' then 1
  when icd9_code = '40410' then 1
  when icd9_code = '40490'         then 1
		end as hhrwohrf  /* Hypertensive heart and renal disease without heart or renal failure */

, CASE
  when icd9_code = '40401' then 1
  when icd9_code = '40411' then 1
  when icd9_code = '40491'         then 1
		end as hhrwchf   /* Hypertensive heart and renal disease with heart failure */

, CASE
  when icd9_code = '40402' then 1
  when icd9_code = '40412' then 1
  when icd9_code = '40492'         then 1
		end as hhrwrf    /* Hypertensive heart and renal disease with renal failure */

, CASE
  when icd9_code = '40403' then 1
  when icd9_code = '40413' then 1
  when icd9_code = '40493'         then 1
		end as hhrwhrf   /* Hypertensive heart and renal disease with heart and renal failure */

, CASE
  when icd9_code between '64270' and '64274' then 1
  when icd9_code between '64290' and '64294' then 1
		end as ohtnpreg  /* Other hypertension in pregnancy */

      /******************** End Temporary Formats ***********************/

, CASE
  when icd9_code between '3420' and '3449' then 1
  when icd9_code between '43820' and '43853' then 1
  when icd9_code = '78072'         then 1
		end as para      /* Paralysis */

, CASE
  when icd9_code between '3300' and '3319' then 1
  when icd9_code = '3320' then 1
  when icd9_code = '3334' then 1
  when icd9_code = '3335' then 1
  when icd9_code = '3337' then 1
  when icd9_code in ('33371','33372','33379','33385','33394') then 1
  when icd9_code between '3340' and '3359' then 1
  when icd9_code = '3380' then 1
  when icd9_code = '340' then 1
  when icd9_code between '3411' and '3419' then 1
  when icd9_code between '34500' and '34511' then 1
  when icd9_code between '3452' and '3453' then 1
  when icd9_code between '34540' and '34591' then 1
  when icd9_code between '34700' and '34701' then 1
  when icd9_code between '34710' and '34711' then 1
  when icd9_code = '3483' then 1 -- discontinued icd-9
  when icd9_code between '64940' and '64944' then 1
  when icd9_code = '7687' then 1
  when icd9_code between '76870' and '76873' then 1
  when icd9_code = '7803' then 1
  when icd9_code = '78031' then 1
  when icd9_code = '78032' then 1
  when icd9_code = '78033' then 1
  when icd9_code = '78039' then 1
  when icd9_code = '78097' then 1
  when icd9_code = '7843'         then 1
		end as neuro     /* Other neurological */

, CASE
  when icd9_code between '490' and '4928' then 1
  when icd9_code between '49300' and '49392' then 1
  when icd9_code between '494' and '4941' then 1
  when icd9_code between '4950' and '505' then 1
  when icd9_code = '5064'         then 1
		end as chrnlung  /* Chronic pulmonary disease */

, CASE
  when icd9_code between '25000' and '25033' then 1
  when icd9_code between '64800' and '64804' then 1
  when icd9_code between '24900' and '24931' then 1
		end as dm        /* Diabetes w/o chronic complications*/

, CASE
  when icd9_code between '25040' and '25093' then 1
  when icd9_code = '7751' then 1
  when icd9_code between '24940' and '24991' then 1
		end as dmcx      /* Diabetes w/ chronic complications */

, CASE
  when icd9_code between '243' and '2442' then 1
  when icd9_code = '2448' then 1
  when icd9_code = '2449'         then 1
		end as hypothy   /* Hypothyroidism */

, CASE
  when icd9_code = '585' then 1 -- discontinued code
  when icd9_code = '5853' then 1
  when icd9_code = '5854' then 1
  when icd9_code = '5855' then 1
  when icd9_code = '5856' then 1
  when icd9_code = '5859' then 1
  when icd9_code = '586' then 1
  when icd9_code = 'V420' then 1
  when icd9_code = 'V451' then 1
  when icd9_code between 'V560' and 'V5632' then 1
  when icd9_code = 'V568' then 1
  when icd9_code between 'V4511' and 'V4512' then 1
		end as renlfail  /* Renal failure */

, CASE
  when icd9_code = '07022' then 1
  when icd9_code = '07023' then 1
  when icd9_code = '07032' then 1
  when icd9_code = '07033' then 1
  when icd9_code = '07044' then 1
  when icd9_code = '07054' then 1
  when icd9_code = '4560' then 1
  when icd9_code = '4561' then 1
  when icd9_code = '45620' then 1
  when icd9_code = '45621' then 1
  when icd9_code = '5710' then 1
  when icd9_code = '5712' then 1
  when icd9_code = '5713' then 1
  when icd9_code between '57140' and '57149' then 1
  when icd9_code = '5715' then 1
  when icd9_code = '5716' then 1
  when icd9_code = '5718' then 1
  when icd9_code = '5719' then 1
  when icd9_code = '5723' then 1
  when icd9_code = '5728' then 1
  when icd9_code = '5735' then 1
  when icd9_code = 'V427'         then 1
		end as liver     /* Liver disease */

, CASE
  when icd9_code = '53141' then 1
  when icd9_code = '53151' then 1
  when icd9_code = '53161' then 1
  when icd9_code = '53170' then 1
  when icd9_code = '53171' then 1
  when icd9_code = '53191' then 1
  when icd9_code = '53241' then 1
  when icd9_code = '53251' then 1
  when icd9_code = '53261' then 1
  when icd9_code = '53270' then 1
  when icd9_code = '53271' then 1
  when icd9_code = '53291' then 1
  when icd9_code = '53341' then 1
  when icd9_code = '53351' then 1
  when icd9_code = '53361' then 1
  when icd9_code = '53370' then 1
  when icd9_code = '53371' then 1
  when icd9_code = '53391' then 1
  when icd9_code = '53441' then 1
  when icd9_code = '53451' then 1
  when icd9_code = '53461' then 1
  when icd9_code = '53470' then 1
  when icd9_code = '53471' then 1
  when icd9_code = '53491'         then 1
		end as ulcer     /* Chronic Peptic ulcer disease (includes bleeding only if obstruction is also present) */

, CASE
  when icd9_code between '042' and '0449' then 1
		end as aids      /* HIV and AIDS */

, CASE
  when icd9_code between '20000' and '20238' then 1
  when icd9_code between '20250' and '20301' then 1
  when icd9_code = '2386' then 1
  when icd9_code = '2733' then 1
  when icd9_code between '20302' and '20382' then 1
		end as lymph     /* Lymphoma */

, CASE
  when icd9_code between '1960' and '1991' then 1
  when icd9_code between '20970' and '20975' then 1
  when icd9_code = '20979' then 1
  when icd9_code = '78951'         then 1
		end as mets      /* Metastatic cancer */

, CASE
  when icd9_code between '1400' and '1729' then 1
  when icd9_code between '1740' and '1759' then 1
  when icd9_code between '179' and '1958' then 1
  when icd9_code between '20900' and '20924' then 1
  when icd9_code between '20925' and '2093' then 1
  when icd9_code between '20930' and '20936' then 1
  when icd9_code between '25801' and '25803' then 1
		end as tumor     /* Solid tumor without metastasis */

, CASE
  when icd9_code = '7010' then 1
  when icd9_code between '7100' and '7109' then 1
  when icd9_code between '7140' and '7149' then 1
  when icd9_code between '7200' and '7209' then 1
  when icd9_code = '725' then 1
		end as arth              /* Rheumatoid arthritis/collagen vascular diseases */

, CASE
  when icd9_code between '2860' and '2869' then 1
  when icd9_code = '2871' then 1
  when icd9_code between '2873' and '2875' then 1
  when icd9_code between '64930' and '64934' then 1
  when icd9_code = '28984'         then 1
		end as coag      /* Coagulation deficiency */

, CASE
  when icd9_code = '2780' then 1
  when icd9_code = '27800' then 1
  when icd9_code = '27801' then 1
  when icd9_code = '27803' then 1
  when icd9_code between '64910' and '64914' then 1
  when icd9_code between 'V8530' and 'V8539' then 1
  when icd9_code = 'V854' then 1 -- hierarchy used for AHRQ v3.6 and earlier
  when icd9_code between 'V8541' and 'V8545' then 1
  when icd9_code = 'V8554' then 1
  when icd9_code = '79391'         then 1
		end as obese     /* Obesity      */

, CASE
  when icd9_code between '260' and '2639' then 1
  when icd9_code between '78321' and '78322' then 1
		end as wghtloss  /* Weight loss */

, CASE
  when icd9_code between '2760' and '2769' then 1
		end as lytes     /* Fluid and electrolyte disorders - note:
                                      this comorbidity should be dropped when
                                      used with the AHRQ Patient Safety Indicators*/
, CASE
  when icd9_code = '2800' then 1
  when icd9_code between '64820' and '64824' then 1
		end as bldloss   /* Blood loss anemia */

, CASE
  when icd9_code between '2801' and '2819' then 1
  when icd9_code between '28521' and '28529' then 1
  when icd9_code = '2859'         then 1
		end as anemdef  /* Deficiency anemias */

, CASE
  when icd9_code between '2910' and '2913' then 1
  when icd9_code = '2915' then 1
  when icd9_code = '2918' then 1
  when icd9_code = '29181' then 1
  when icd9_code = '29182' then 1
  when icd9_code = '29189' then 1
  when icd9_code = '2919' then 1
  when icd9_code between '30300' and '30393' then 1
  when icd9_code between '30500' and '30503' then 1
		end as alcohol   /* Alcohol abuse */

, CASE
  when icd9_code = '2920' then 1
  when icd9_code between '29282' and '29289' then 1
  when icd9_code = '2929' then 1
  when icd9_code between '30400' and '30493' then 1
  when icd9_code between '30520' and '30593' then 1
  when icd9_code between '64830' and '64834' then 1
		end as drug      /* Drug abuse */

, CASE
  when icd9_code between '29500' and '2989' then 1
  when icd9_code = '29910' then 1
  when icd9_code = '29911'         then 1
		end as psych    /* Psychoses */

, CASE
  when icd9_code = '3004' then 1
  when icd9_code = '30112' then 1
  when icd9_code = '3090' then 1
  when icd9_code = '3091' then 1
  when icd9_code = '311'         then 1
		end as depress  /* Depression */
from `physionet-data.mimiciii_clinical.diagnoses_icd` icd
WHERE seq_num = 1
)
-- collapse the icd9_code specific flags into hadm_id specific flags
-- this groups comorbidities together for a single patient admission
, eligrp as
(
  select hadm_id
  , max(chf) as chf
  , max(arythm) as arythm
  , max(valve) as valve
  , max(pulmcirc) as pulmcirc
  , max(perivasc) as perivasc
  , max(htn) as htn
  , max(htncx) as htncx
  , max(htnpreg) as htnpreg
  , max(htnwochf) as htnwochf
  , max(htnwchf) as htnwchf
  , max(hrenworf) as hrenworf
  , max(hrenwrf) as hrenwrf
  , max(hhrwohrf) as hhrwohrf
  , max(hhrwchf) as hhrwchf
  , max(hhrwrf) as hhrwrf
  , max(hhrwhrf) as hhrwhrf
  , max(ohtnpreg) as ohtnpreg
  , max(para) as para
  , max(neuro) as neuro
  , max(chrnlung) as chrnlung
  , max(dm) as dm
  , max(dmcx) as dmcx
  , max(hypothy) as hypothy
  , max(renlfail) as renlfail
  , max(liver) as liver
  , max(ulcer) as ulcer
  , max(aids) as aids
  , max(lymph) as lymph
  , max(mets) as mets
  , max(tumor) as tumor
  , max(arth) as arth
  , max(coag) as coag
  , max(obese) as obese
  , max(wghtloss) as wghtloss
  , max(lytes) as lytes
  , max(bldloss) as bldloss
  , max(anemdef) as anemdef
  , max(alcohol) as alcohol
  , max(drug) as drug
  , max(psych) as psych
  , max(depress) as depress
from eliflg
group by hadm_id
)
-- now merge these flags together to define elixhauser
-- most are straightforward.. but hypertension flags are a bit more complicated
select adm.subject_id, adm.hadm_id
, case
    when chf     = 1 then 1
    when htnwchf = 1 then 1
    when hhrwchf = 1 then 1
    when hhrwhrf = 1 then 1
  else 0 end as congestive_heart_failure
, case
    when arythm = 1 then 1
  else 0 end as cardiac_arrhythmias
, case when    valve = 1 then 1 else 0 end as valvular_disease
, case when pulmcirc = 1 then 1 else 0 end as pulmonary_circulation
, case when perivasc = 1 then 1 else 0 end as peripheral_vascular

-- we combine "htn" and "htncx" into "HYPERTENSION"
-- note "htn" (hypertension) is only 1 if "htncx" (complicated hypertension) is 0
-- this matters if you filter on DRG but for this query we can just merge them immediately
, case
    when htn = 1 then 1
    when htncx = 1 then 1
    when htnpreg = 1 then 1
    when htnwochf = 1 then 1
    when htnwchf = 1 then 1
    when hrenworf = 1 then 1
    when hrenwrf = 1 then 1
    when hhrwohrf = 1 then 1
    when hhrwchf = 1 then 1
    when hhrwrf = 1 then 1
    when hhrwhrf = 1 then 1
    when ohtnpreg = 1 then 1
  else 0 end as hypertension

, case when para      = 1 then 1 else 0 end as paralysis
, case when neuro     = 1 then 1 else 0 end as other_neurological
, case when chrnlung  = 1 then 1 else 0 end as chronic_pulmonary
, case
    -- only the more severe comorbidity (complicated diabetes) is kept
    when dmcx = 1 then 0
    when dm = 1 then 1
  else 0 end as diabetes_uncomplicated
, case when dmcx    = 1 then 1 else 0 end as diabetes_complicated
, case when hypothy = 1 then 1 else 0 end as hypothyroidism
, case
    when renlfail = 1 then 1
    when hrenwrf  = 1 then 1
    when hhrwrf   = 1 then 1
    when hhrwhrf  = 1 then 1
  else 0 end as renal_failure

, case when liver = 1 then 1 else 0 end as liver_disease
, case when ulcer = 1 then 1 else 0 end as peptic_ulcer
, case when aids = 1 then 1 else 0 end as aids
, case when lymph = 1 then 1 else 0 end as lymphoma
, case when mets = 1 then 1 else 0 end as metastatic_cancer
, case
    -- only the more severe comorbidity (metastatic cancer) is kept
    when mets = 1 then 0
    when tumor = 1 then 1
  else 0 end as solid_tumor
, case when arth = 1 then 1 else 0 end as rheumatoid_arthritis
, case when coag = 1 then 1 else 0 end as coagulopathy
, case when obese = 1 then 1 else 0 end as obesity
, case when wghtloss = 1 then 1 else 0 end as weight_loss
, case when lytes = 1 then 1 else 0 end as fluid_electrolyte
, case when bldloss = 1 then 1 else 0 end as blood_loss_anemia
, case when anemdef = 1 then 1 else 0 end as deficiency_anemias
, case when alcohol = 1 then 1 else 0 end as alcohol_abuse
, case when drug = 1 then 1 else 0 end as drug_abuse
, case when psych = 1 then 1 else 0 end as psychoses
, case when depress = 1 then 1 else 0 end as depression

FROM `physionet-data.mimiciii_clinical.admissions` adm
left join eligrp eli
  on adm.hadm_id = eli.hadm_id
order by adm.hadm_id;
