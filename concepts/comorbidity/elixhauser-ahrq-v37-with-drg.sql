-- This code uses the latest version of Elixhauser provided by AHRQ


-- first, we convert ICD9_CODE from a VARCHAR to a CHAR(5)
-- this is the format used in the SAS code provided by the AHRQ
-- it makes converting their code to SQL much simpler as we can directly use their syntax

-- also note, that we *cannot* skip this step and use a varchar here
-- why? well, for example, VALVE is coded as BETWEEN '4240 ' and '42499'
-- if we used a varchar, then '4240' *is not* between this range
-- but if we use a char(5), then '4240' *is* between this range
-- and we would like the latter behavior
-- it's possible removing the whitespaces would fix this - but I didn't test it.
-- I prefer consistency with AHRQ.

DROP MATERIALIZED VIEW IF EXISTS ELIXHAUSER_AHRQ CASCADE;
CREATE MATERIALIZED VIEW ELIXHAUSER_AHRQ as
with
icd as
(
  select hadm_id, subject_id, seq_num
    , cast(icd9_code as char(5)) as icd9_code
  from diagnoses_icd
  where seq_num != 1 -- we do not include the primary icd-9 code
)
,
eliflg as
(
select hadm_id, subject_id, seq_num, icd9_code
-- note that these codes will seem incomplete at first
-- for example, CHF is missing a lot of codes referenced in the literature (402.11, 402.91, etc)
-- these codes are captured by hypertension flags instead
-- later there are some complicated rules which confirm/reject those codes as CHF
, CASE
  when icd9_code = '39891' then 1
  when icd9_code between '4280 ' and '4289 ' then 1
		end as CHF       /* Congestive heart failure */

-- cardiac arrhythmias is removed in up to date versions
, case
    when icd9_code = '42610' then 1
    when icd9_code = '42611' then 1
    when icd9_code = '42613' then 1
    when icd9_code between '4262 ' and '42653' then 1
    when icd9_code between '4266 ' and '42689' then 1
    when icd9_code = '4270 ' then 1
    when icd9_code = '4272 ' then 1
    when icd9_code = '42731' then 1
    when icd9_code = '42760' then 1
    when icd9_code = '4279 ' then 1
    when icd9_code = '7850 ' then 1
    when icd9_code between 'V450 ' and 'V4509' then 1
    when icd9_code between 'V533 ' and 'V5339' then 1
  end as ARYTHM /* Cardiac arrhythmias */

, CASE
  when icd9_code between '09320' and '09324' then 1
  when icd9_code between '3940 ' and '3971 ' then 1
  when icd9_code = '3979 ' then 1
  when icd9_code between '4240 ' and '42499' then 1
  when icd9_code between '7463 ' and '7466 ' then 1
  when icd9_code = 'V422 ' then 1
  when icd9_code = 'V433 ' then 1
		end as VALVE     /* Valvular disease */

, CASE
  when icd9_code between '41511' and '41519' then 1
  when icd9_code between '4160 ' and '4169 ' then 1
  when icd9_code = '4179 ' then 1
		end as PULMCIRC  /* Pulmonary circulation disorder */

, CASE
  when icd9_code between '4400 ' and '4409 ' then 1
  when icd9_code between '44100' and '4419 ' then 1
  when icd9_code between '4420 ' and '4429 ' then 1
  when icd9_code between '4431 ' and '4439 ' then 1
  when icd9_code between '44421' and '44422' then 1
  when icd9_code = '4471 ' then 1
  when icd9_code = '449  ' then 1
  when icd9_code = '5571 ' then 1
  when icd9_code = '5579 ' then 1
  when icd9_code = 'V434 ' then 1
		end as PERIVASC  /* Peripheral vascular disorder */

, CASE
  when icd9_code = '4011 ' then 1
  when icd9_code = '4019 ' then 1
  when icd9_code between '64200' and '64204' then 1
		end as HTN       /* Hypertension, uncomplicated */

, CASE
  when icd9_code = '4010 ' then 1
  when icd9_code = '4372 ' then 1
		end as HTNCX     /* Hypertension, complicated */


      /******************************************************************/
      /* The following are special, temporary formats used in the       */
      /* creation of the hypertension complicated comorbidity when      */
      /* overlapping with congestive heart failure or renal failure     */
      /* occurs. These temporary formats are referenced in the program  */
      /* called comoanaly2009.txt.                                      */
      /******************************************************************/
, CASE
  when icd9_code between '64220' and '64224' then 1
		end as HTNPREG   /* Pre-existing hypertension complicating pregnancy */

, CASE
  when icd9_code = '40200' then 1
  when icd9_code = '40210' then 1
  when icd9_code = '40290' then 1
  when icd9_code = '40509' then 1
  when icd9_code = '40519' then 1
  when icd9_code = '40599'         then 1
		end as HTNWOCHF  /* Hypertensive heart disease without heart failure */

, CASE
  when icd9_code = '40201' then 1
  when icd9_code = '40211' then 1
  when icd9_code = '40291'         then 1
		end as HTNWCHF   /* Hypertensive heart disease with heart failure */

, CASE
  when icd9_code = '40300' then 1
  when icd9_code = '40310' then 1
  when icd9_code = '40390' then 1
  when icd9_code = '40501' then 1
  when icd9_code = '40511' then 1
  when icd9_code = '40591' then 1
  when icd9_code between '64210' and '64214' then 1
		end as HRENWORF  /* Hypertensive renal disease without renal failure */

, CASE
  when icd9_code = '40301' then 1
  when icd9_code = '40311' then 1
  when icd9_code = '40391'         then 1
		end as HRENWRF   /* Hypertensive renal disease with renal failure */

, CASE
  when icd9_code = '40400' then 1
  when icd9_code = '40410' then 1
  when icd9_code = '40490'         then 1
		end as HHRWOHRF  /* Hypertensive heart and renal disease without heart or renal failure */

, CASE
  when icd9_code = '40401' then 1
  when icd9_code = '40411' then 1
  when icd9_code = '40491'         then 1
		end as HHRWCHF   /* Hypertensive heart and renal disease with heart failure */

, CASE
  when icd9_code = '40402' then 1
  when icd9_code = '40412' then 1
  when icd9_code = '40492'         then 1
		end as HHRWRF    /* Hypertensive heart and renal disease with renal failure */

, CASE
  when icd9_code = '40403' then 1
  when icd9_code = '40413' then 1
  when icd9_code = '40493'         then 1
		end as HHRWHRF   /* Hypertensive heart and renal disease with heart and renal failure */

, CASE
  when icd9_code between '64270' and '64274' then 1
  when icd9_code between '64290' and '64294' then 1
		end as OHTNPREG  /* Other hypertension in pregnancy */

      /******************** End Temporary Formats ***********************/

, CASE
  when icd9_code between '3420 ' and '3449 ' then 1
  when icd9_code between '43820' and '43853' then 1
  when icd9_code = '78072'         then 1
		end as PARA      /* Paralysis */

, CASE
  when icd9_code between '3300 ' and '3319 ' then 1
  when icd9_code = '3320 ' then 1
  when icd9_code = '3334 ' then 1
  when icd9_code = '3335 ' then 1
  when icd9_code = '3337 ' then 1
  when icd9_code in ('33371','33372','33379','33385','33394') then 1
  when icd9_code between '3340 ' and '3359 ' then 1
  when icd9_code = '3380 ' then 1
  when icd9_code = '340  ' then 1
  when icd9_code between '3411 ' and '3419 ' then 1
  when icd9_code between '34500' and '34511' then 1
  when icd9_code between '3452 ' and '3453 ' then 1
  when icd9_code between '34540' and '34591' then 1
  when icd9_code between '34700' and '34701' then 1
  when icd9_code between '34710' and '34711' then 1
  when icd9_code = '3483' then 1 -- discontinued icd-9
  when icd9_code between '64940' and '64944' then 1
  when icd9_code = '7687 ' then 1
  when icd9_code between '76870' and '76873' then 1
  when icd9_code = '7803 ' then 1
  when icd9_code = '78031' then 1
  when icd9_code = '78032' then 1
  when icd9_code = '78033' then 1
  when icd9_code = '78039' then 1
  when icd9_code = '78097' then 1
  when icd9_code = '7843 '         then 1
		end as NEURO     /* Other neurological */

, CASE
  when icd9_code between '490  ' and '4928 ' then 1
  when icd9_code between '49300' and '49392' then 1
  when icd9_code between '494  ' and '4941 ' then 1
  when icd9_code between '4950 ' and '505  ' then 1
  when icd9_code = '5064 '         then 1
		end as CHRNLUNG  /* Chronic pulmonary disease */

, CASE
  when icd9_code between '25000' and '25033' then 1
  when icd9_code between '64800' and '64804' then 1
  when icd9_code between '24900' and '24931' then 1
		end as DM        /* Diabetes w/o chronic complications*/

, CASE
  when icd9_code between '25040' and '25093' then 1
  when icd9_code = '7751 ' then 1
  when icd9_code between '24940' and '24991' then 1
		end as DMCX      /* Diabetes w/ chronic complications */

, CASE
  when icd9_code between '243  ' and '2442 ' then 1
  when icd9_code = '2448 ' then 1
  when icd9_code = '2449 '         then 1
		end as HYPOTHY   /* Hypothyroidism */

, CASE
  when icd9_code = '585  ' then 1 -- discontinued code
  when icd9_code = '5853 ' then 1
  when icd9_code = '5854 ' then 1
  when icd9_code = '5855 ' then 1
  when icd9_code = '5856 ' then 1
  when icd9_code = '5859 ' then 1
  when icd9_code = '586  ' then 1
  when icd9_code = 'V420 ' then 1
  when icd9_code = 'V451 ' then 1
  when icd9_code between 'V560 ' and 'V5632' then 1
  when icd9_code = 'V568 ' then 1
  when icd9_code between 'V4511' and 'V4512' then 1
		end as RENLFAIL  /* Renal failure */

, CASE
  when icd9_code = '07022' then 1
  when icd9_code = '07023' then 1
  when icd9_code = '07032' then 1
  when icd9_code = '07033' then 1
  when icd9_code = '07044' then 1
  when icd9_code = '07054' then 1
  when icd9_code = '4560 ' then 1
  when icd9_code = '4561 ' then 1
  when icd9_code = '45620' then 1
  when icd9_code = '45621' then 1
  when icd9_code = '5710 ' then 1
  when icd9_code = '5712 ' then 1
  when icd9_code = '5713 ' then 1
  when icd9_code between '57140' and '57149' then 1
  when icd9_code = '5715 ' then 1
  when icd9_code = '5716 ' then 1
  when icd9_code = '5718 ' then 1
  when icd9_code = '5719 ' then 1
  when icd9_code = '5723 ' then 1
  when icd9_code = '5728 ' then 1
  when icd9_code = '5735 ' then 1
  when icd9_code = 'V427 '         then 1
		end as LIVER     /* Liver disease */

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
		end as ULCER     /* Chronic Peptic ulcer disease (includes bleeding only if obstruction is also present) */

, CASE
  when icd9_code between '042  ' and '0449 ' then 1
		end as AIDS      /* HIV and AIDS */

, CASE
  when icd9_code between '20000' and '20238' then 1
  when icd9_code between '20250' and '20301' then 1
  when icd9_code = '2386 ' then 1
  when icd9_code = '2733 ' then 1
  when icd9_code between '20302' and '20382' then 1
		end as LYMPH     /* Lymphoma */

, CASE
  when icd9_code between '1960 ' and '1991 ' then 1
  when icd9_code between '20970' and '20975' then 1
  when icd9_code = '20979' then 1
  when icd9_code = '78951'         then 1
		end as METS      /* Metastatic cancer */

, CASE
  when icd9_code between '1400 ' and '1729 ' then 1
  when icd9_code between '1740 ' and '1759 ' then 1
  when icd9_code between '179  ' and '1958 ' then 1
  when icd9_code between '20900' and '20924' then 1
  when icd9_code between '20925' and '2093 ' then 1
  when icd9_code between '20930' and '20936' then 1
  when icd9_code between '25801' and '25803' then 1
		end as TUMOR     /* Solid tumor without metastasis */

, CASE
  when icd9_code = '7010 ' then 1
  when icd9_code between '7100 ' and '7109 ' then 1
  when icd9_code between '7140 ' and '7149 ' then 1
  when icd9_code between '7200 ' and '7209 ' then 1
  when icd9_code = '725  ' then 1
		end as ARTH              /* Rheumatoid arthritis/collagen vascular diseases */

, CASE
  when icd9_code between '2860 ' and '2869 ' then 1
  when icd9_code = '2871 ' then 1
  when icd9_code between '2873 ' and '2875 ' then 1
  when icd9_code between '64930' and '64934' then 1
  when icd9_code = '28984'         then 1
		end as COAG      /* Coagulation deficiency */

, CASE
  when icd9_code = '2780 ' then 1
  when icd9_code = '27800' then 1
  when icd9_code = '27801' then 1
  when icd9_code = '27803' then 1
  when icd9_code between '64910' and '64914' then 1
  when icd9_code between 'V8530' and 'V8539' then 1
  when icd9_code = 'V854 ' then 1 -- hierarchy used for AHRQ v3.6 and earlier
  when icd9_code between 'V8541' and 'V8545' then 1
  when icd9_code = 'V8554' then 1
  when icd9_code = '79391'         then 1
		end as OBESE     /* Obesity      */

, CASE
  when icd9_code between '260  ' and '2639 ' then 1
  when icd9_code between '78321' and '78322' then 1
		end as WGHTLOSS  /* Weight loss */

, CASE
  when icd9_code between '2760 ' and '2769 ' then 1
		end as LYTES     /* Fluid and electrolyte disorders - note:
                                      this comorbidity should be dropped when
                                      used with the AHRQ Patient Safety Indicators*/
, CASE
  when icd9_code = '2800 ' then 1
  when icd9_code between '64820' and '64824' then 1
		end as BLDLOSS   /* Blood loss anemia */

, CASE
  when icd9_code between '2801 ' and '2819 ' then 1
  when icd9_code between '28521' and '28529' then 1
  when icd9_code = '2859 '         then 1
		end as ANEMDEF  /* Deficiency anemias */

, CASE
  when icd9_code between '2910 ' and '2913 ' then 1
  when icd9_code = '2915 ' then 1
  when icd9_code = '2918 ' then 1
  when icd9_code = '29181' then 1
  when icd9_code = '29182' then 1
  when icd9_code = '29189' then 1
  when icd9_code = '2919 ' then 1
  when icd9_code between '30300' and '30393' then 1
  when icd9_code between '30500' and '30503' then 1
		end as ALCOHOL   /* Alcohol abuse */

, CASE
  when icd9_code = '2920 ' then 1
  when icd9_code between '29282' and '29289' then 1
  when icd9_code = '2929 ' then 1
  when icd9_code between '30400' and '30493' then 1
  when icd9_code between '30520' and '30593' then 1
  when icd9_code between '64830' and '64834' then 1
		end as DRUG      /* Drug abuse */

, CASE
  when icd9_code between '29500' and '2989 ' then 1
  when icd9_code = '29910' then 1
  when icd9_code = '29911'         then 1
		end as PSYCH    /* Psychoses */

, CASE
  when icd9_code = '3004 ' then 1
  when icd9_code = '30112' then 1
  when icd9_code = '3090 ' then 1
  when icd9_code = '3091 ' then 1
  when icd9_code = '311  '         then 1
		end as DEPRESS  /* Depression */
from icd
)
-- collapse the icd9_code specific flags into hadm_id specific flags
-- this groups comorbidities together for a single patient admission
, eligrp as
(
  select hadm_id, subject_id
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
group by hadm_id, subject_id
)

-- DRG FILTER --
, msdrg as
(
select
  hadm_id, subject_id
/**** V29 MS-DRG Formats ****/

/* Cardiac */
, case
    when d.drg_code between 001 and 002 then 1
    when d.drg_code between 215 and 238 then 1
    when d.drg_code between 242 and 252 then 1
    when d.drg_code between 253 and 254 then 1
    when d.drg_code between 258 and 262 then 1
    when d.drg_code between 265 and 267 then 1
    when d.drg_code between 280 and 293 then 1
    when d.drg_code between 296 and 298 then 1
    when d.drg_code between 302 and 303 then 1
    when d.drg_code between 306 and 313 then 1
else 0 end as CARDDRG

/* Peripheral vascular */
, case
    when d.drg_code between 299 and 301 then 1
else 0 end as PERIDRG

/* Renal */
, case
    when d.drg_code = 652 then 1
    when d.drg_code between 656 and 661 then 1
    when d.drg_code between 673 and 675 then 1
    when d.drg_code between 682 and 700 then 1
else 0 end as RENALDRG

/* Nervous system */
, case
    when d.drg_code between 020 and 042 then 1
    when d.drg_code between 052 and 103 then 1
else 0 end as NERVDRG

/* Cerebrovascular */
, case
    when d.drg_code between 020 and 022 then 1
    when d.drg_code between 034 and 039 then 1
    when d.drg_code between 064 and 072 then 1
else 0 end as CEREDRG

/* COPD asthma */
, case
    when d.drg_code between 190 and 192 then 1
    when d.drg_code between 202 and 203 then 1
else 0 end as PULMDRG

/* Diabetes */
, case
    when d.drg_code between 637 and 639 then 1
else 0 end as  DIABDRG

/* Thyroid endocrine */
, case
    when d.drg_code between 625 and 627 then 1
    when d.drg_code between 643 and 645 then 1
else 0 end as HYPODRG

/* Kidney transp, renal fail/dialysis */
, case
    when d.drg_code = 652 then 1
    when d.drg_code between 682 and 685 then 1
else 0 end as RENFDRG

/* Liver */
, case
    when d.drg_code between 420 and 425 then 1
    when d.drg_code between 432 and 434 then 1
    when d.drg_code between 441 and 446 then 1
else 0 end as LIVERDRG

/* GI hemorrhage or ulcer */
, case
    when d.drg_code between 377 and 384 then 1
else 0 end as ULCEDRG

/* Human immunodeficiency virus */
, case
    when d.drg_code between 969 and 970 then 1
    when d.drg_code between 974 and 977 then 1
else 0 end as HIVDRG

/* Leukemia/lymphoma */
, case
    when d.drg_code between 820 and 830 then 1
    when d.drg_code between 834 and 849 then 1
else 0 end as LEUKDRG

/* Cancer, lymphoma */
, case
    when d.drg_code = 054 then 1
    when d.drg_code = 055 then 1
    when d.drg_code between 146 and 148 then 1
    when d.drg_code between 180 and 182 then 1
    when d.drg_code between 374 and 376 then 1
    when d.drg_code between 435 and 437 then 1
    when d.drg_code between 542 and 544 then 1
    when d.drg_code between 582 and 585 then 1
    when d.drg_code between 597 and 599 then 1
    when d.drg_code between 656 and 658 then 1
    when d.drg_code between 686 and 688 then 1
    when d.drg_code between 715 and 716 then 1
    when d.drg_code between 722 and 724 then 1
    when d.drg_code between 736 and 741 then 1
    when d.drg_code between 754 and 756 then 1
    when d.drg_code between 826 and 830 then 1
    when d.drg_code between 843 and 849 then 1
else 0 end as CANCDRG

/* Connective tissue */
, case
    when d.drg_code between 545 and 547 then 1
else 0 end as ARTHDRG

/* Nutrition/metabolic */
, case
    when d.drg_code between 640 and 641 then 1
else 0 end as NUTRDRG

/* Anemia */
, case
    when d.drg_code between 808 and 812 then 1
else 0 end as ANEMDRG

/* Alcohol drug */
, case
    when d.drg_code between 894 and 897 then 1
else 0 end as ALCDRG

/*Coagulation disorders*/
, case
    when d.drg_code = 813 then 1
else 0 end as COAGDRG

/*Hypertensive Complicated  */
, case
    when d.drg_code = 077 then 1
    when d.drg_code = 078 then 1
    when d.drg_code = 304 then 1
else 0 end as HTNCXDRG

/*Hypertensive Uncomplicated  */
, case
    when d.drg_code = 079 then 1
    when d.drg_code = 305 then 1
else 0 end as HTNDRG

/* Psychoses */
, case
    when d.drg_code = 885 then 1
else 0 end as PSYDRG

/* Obesity */
, case
    when d.drg_code between 619 and 621 then 1
else 0 end as OBESEDRG

/* Depressive Neuroses */
, case
    when d.drg_code = 881 then 1
else 0 end as DEPRSDRG

from
(
  select hadm_id, subject_id, drg_type, cast(drg_code as numeric) as drg_code from drgcodes where drg_type = 'MS'
) d

)
, hcfadrg as
(
select
  hadm_id, subject_id

  /** V24 DRG Formats  **/

  /* Cardiac */
  , case
      when d.drg_code between 103 and 112 then 1
      when d.drg_code between 115 and 118 then 1
      when d.drg_code between 121 and 127 then 1
      when d.drg_code = 129 then 1
      when d.drg_code = 132 then 1
      when d.drg_code = 133 then 1
      when d.drg_code between 135 and 143 then 1
      when d.drg_code between 514 and 518 then 1
      when d.drg_code between 525 and 527 then 1
      when d.drg_code between 535 and 536 then 1
      when d.drg_code between 547 and 550 then 1
      when d.drg_code between 551 and 558 then 1
  else 0 end as CARDDRG

  /* Peripheral vascular */
  , case
      when d.drg_code = 130 then 1
      when d.drg_code = 131 then 1
  else 0 end as PERIDRG

  /* Renal */
  , case
      when d.drg_code between 302 and 305 then 1
      when d.drg_code between 315 and 333 then 1

  else 0 end as RENALDRG

  /* Nervous system */
  , case
      when d.drg_code between 1 and 35 then 1
      when d.drg_code = 524 then 1
      when d.drg_code between 528 and 534 then 1
      when d.drg_code = 543 then 1
      when d.drg_code between 559 and 564 then 1
      when d.drg_code = 577 then 1

  else 0 end as NERVDRG

   /* Cerebrovascular */
  , case
      when d.drg_code = 5 then 1
      when d.drg_code between 14 and 17 then 1
      when d.drg_code = 524 then 1
      when d.drg_code = 528 then 1
      when d.drg_code between 533 and 534 then 1
      when d.drg_code = 577 then 1
  else 0 end as CEREDRG

  /* COPD asthma */
  , case
      when d.drg_code = 88 then 1
      when d.drg_code between 96 and 98 then 1

  else 0 end as PULMDRG

  /* Diabetes */
  , case
      when d.drg_code = 294 then 1
      when d.drg_code = 295 then 1
  else 0 end as DIABDRG

  /* Thyroid endocrine */
  , case
      when d.drg_code = 290 then 1
      when d.drg_code = 300 then 1
      when d.drg_code = 301 then 1

  else 0 end as HYPODRG

  /* Kidney transp, renal fail/dialysis */
  , case
      when d.drg_code = 302 then 1
      when d.drg_code = 316 then 1
      when d.drg_code = 317 then 1
  else 0 end as RENFDRG

  /* Liver */
  , case
      when d.drg_code between 199 and 202 then 1
      when d.drg_code between 205 and 208 then 1

  else 0 end as LIVERDRG

  /* GI hemorrhage or ulcer */
  , case
      when d.drg_code between 174 and 178 then 1
  else 0 end as ULCEDRG

  /* Human immunodeficiency virus */
  , case
      when d.drg_code = 488 then 1
      when d.drg_code = 489 then 1
      when d.drg_code = 490 then 1

  else 0 end as HIVDRG

  /* Leukemia/lymphoma */
  , case
      when d.drg_code between 400 and 414 then 1
      when d.drg_code = 473 then 1
      when d.drg_code = 492 then 1
      when d.drg_code between 539 and 540 then 1

  else 0 end as LEUKDRG

  /* Cancer, lymphoma */
  , case
      when d.drg_code = 10 then 1
      when d.drg_code = 11 then 1
      when d.drg_code = 64 then 1
      when d.drg_code = 82 then 1
      when d.drg_code = 172 then 1
      when d.drg_code = 173 then 1
      when d.drg_code = 199 then 1
      when d.drg_code = 203 then 1
      when d.drg_code = 239 then 1

      when d.drg_code between 257 and 260 then 1
      when d.drg_code = 274 then 1
      when d.drg_code = 275 then 1
      when d.drg_code = 303 then 1
      when d.drg_code = 318 then 1
      when d.drg_code = 319 then 1

      when d.drg_code = 338 then 1
      when d.drg_code = 344 then 1
      when d.drg_code = 346 then 1
      when d.drg_code = 347 then 1
      when d.drg_code = 354 then 1
      when d.drg_code = 355 then 1
      when d.drg_code = 357 then 1
      when d.drg_code = 363 then 1
      when d.drg_code = 366 then 1

      when d.drg_code = 367 then 1
      when d.drg_code between 406 and 414 then 1
  else 0 end as CANCDRG

  /* Connective tissue */
  , case
      when d.drg_code = 240 then 1
      when d.drg_code = 241 then 1
  else 0 end as ARTHDRG

  /* Nutrition/metabolic */
  , case
      when d.drg_code between 296 and 298 then 1
  else 0 end as NUTRDRG

  /* Anemia */
  , case
      when d.drg_code = 395 then 1
      when d.drg_code = 396 then 1
      when d.drg_code = 574 then 1
  else 0 end as ANEMDRG

  /* Alcohol drug */
  , case
      when d.drg_code between 433 and 437 then 1
      when d.drg_code between 521 and 523 then 1
  else 0 end as ALCDRG

  /* Coagulation disorders */
  , case
      when d.drg_code = 397 then 1
  else 0 end as COAGDRG

  /* Hypertensive Complicated */
  , case
      when d.drg_code = 22 then 1
      when d.drg_code = 134 then 1
  else 0 end as HTNCXDRG

  /* Hypertensive Uncomplicated */
  , case
      when d.drg_code = 134 then 1
  else 0 end as HTNDRG

  /* Psychoses */
  , case
      when d.drg_code = 430 then 1
  else 0 end as PSYDRG

  /* Obesity */
  , case
      when d.drg_code = 288 then 1
  else 0 end as OBESEDRG

  /* Depressive Neuroses */
  , case
      when d.drg_code = 426 then 1
  else 0 end as DEPRSDRG

  from
  (
    select hadm_id, subject_id, drg_type, cast(drg_code as numeric) as drg_code from drgcodes where drg_type = 'HCFA'
  ) d
)
-- merge DRG groups together
, drggrp as
(
  select hadm_id, subject_id
, max(carddrg) as carddrg
, max(peridrg) as peridrg
, max(renaldrg) as renaldrg
, max(nervdrg) as nervdrg
, max(ceredrg) as ceredrg
, max(pulmdrg) as pulmdrg
, max(diabdrg) as diabdrg
, max(hypodrg) as hypodrg
, max(renfdrg) as renfdrg
, max(liverdrg) as liverdrg
, max(ulcedrg) as ulcedrg
, max(hivdrg) as hivdrg
, max(leukdrg) as leukdrg
, max(cancdrg) as cancdrg
, max(arthdrg) as arthdrg
, max(nutrdrg) as nutrdrg
, max(anemdrg) as anemdrg
, max(alcdrg) as alcdrg
, max(coagdrg) as coagdrg
, max(htncxdrg) as htncxdrg
, max(htndrg) as htndrg
, max(psydrg) as psydrg
, max(obesedrg) as obesedrg
, max(deprsdrg) as deprsdrg
from
(
  select d1.* from msdrg d1
  UNION
  select d1.* from hcfadrg d1
) d
group by d.hadm_id, d.subject_id
)
-- now merge these flags together to define elixhauser
-- most are straightforward.. but hypertension flags are a bit more complicated
select adm.subject_id, adm.hadm_id
, case
    when carddrg = 1 then 0 -- DRG filter

    when chf     = 1 then 1
    when htnwchf = 1 then 1
    when hhrwchf = 1 then 1
    when hhrwhrf = 1 then 1
  else 0 end as CONGESTIVE_HEART_FAILURE
, case
    when carddrg = 1 then 0 -- DRG filter
    when arythm = 1 then 1
  else 0 end as CARDIAC_ARRHYTHMIAS
, case
    when carddrg = 1 then 0
    when valve = 1 then 1
  else 0 end as VALVULAR_DISEASE
, case
    when carddrg = 1 or pulmdrg = 1 then 0
    when pulmcirc = 1 then 1
    else 0 end as PULMONARY_CIRCULATION
, case
    when peridrg  = 1 then 0
    when perivasc = 1 then 1
    else 0 end as PERIPHERAL_VASCULAR

-- we combine 'htn' and 'htncx' into 'HYPERTENSION'
-- note 'htn' (hypertension) is only 1 if 'htncx' (complicated hypertension) is 0
-- also if htncxdrg = 1, then htndrg = 1

-- In the original SAS code, it appears that:
--  HTN can be 1
--  HTNCX is set to 0 by DRGs
--  but HTN_C is still 1, because HTN is 1
-- so we have to do this complex addition.
,
case
  when
(
-- first hypertension
case
  when htndrg = 0 then 0
  when htn = 1 then 1
else 0 end
)
+
(
-- next complicated hypertension
case
    when htncx    = 1 and htncxdrg = 1 then 0

    when htnpreg  = 1 and htncxdrg = 1 then 0
    when htnwochf = 1 and (htncxdrg = 1 OR carddrg = 1) then 0
    when htnwchf  = 1 and htncxdrg = 1 then 0
    when htnwchf  = 1 and carddrg = 1 then 0
    when hrenworf = 1 and (htncxdrg = 1 or renaldrg = 1) then 0
    when hrenwrf  = 1 and htncxdrg = 1 then 0
    when hrenwrf  = 1 and renaldrg = 1 then 0
    when hhrwohrf = 1 and (htncxdrg = 1 or carddrg = 1 or renaldrg = 1) then 0
    when hhrwchf  = 1 and (htncxdrg = 1 or carddrg = 1 or renaldrg = 1) then 0
    when hhrwrf   = 1 and (htncxdrg = 1 or carddrg = 1 or renaldrg = 1) then 0
    when hhrwhrf  = 1 and (htncxdrg = 1 or carddrg = 1 or renaldrg = 1) then 0
    when ohtnpreg = 1 and (htncxdrg = 1 or carddrg = 1 or renaldrg = 1) then 0

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
  else 0 end
)
  > 0 then 1 else 0 end as HYPERTENSION

, case when ceredrg = 1 then 0 when para      = 1 then 1 else 0 end as PARALYSIS
, case when nervdrg = 1 then 0 when neuro     = 1 then 1 else 0 end as OTHER_NEUROLOGICAL
, case when pulmdrg = 1 then 0 when chrnlung  = 1 then 1 else 0 end as CHRONIC_PULMONARY
, case
    -- only the more severe comorbidity (complicated diabetes) is kept
    when diabdrg = 1 then 0
    when dmcx = 1 then 0
    when dm = 1 then 1
  else 0 end as DIABETES_UNCOMPLICATED
, case when diabdrg = 1 then 0 when dmcx    = 1 then 1 else 0 end as DIABETES_COMPLICATED
, case when hypodrg = 1 then 0 when hypothy = 1 then 1 else 0 end as HYPOTHYROIDISM
, case
    when renaldrg = 1 then 0
    when renlfail = 1 then 1
    when hrenwrf  = 1 then 1
    when hhrwrf   = 1 then 1
    when hhrwhrf  = 1 then 1
  else 0 end as RENAL_FAILURE

, case when liverdrg  = 1 then 0 when liver = 1 then 1 else 0 end as LIVER_DISEASE
, case when ulcedrg   = 1 then 0 when ulcer = 1 then 1 else 0 end as PEPTIC_ULCER
, case when hivdrg    = 1 then 0 when aids = 1 then 1 else 0 end as AIDS
, case when leukdrg   = 1 then 0 when lymph = 1 then 1 else 0 end as LYMPHOMA
, case when cancdrg   = 1 then 0 when mets = 1 then 1 else 0 end as METASTATIC_CANCER
, case
    when cancdrg = 1 then 0
    -- only the more severe comorbidity (metastatic cancer) is kept
    when mets = 1 then 0
    when tumor = 1 then 1
  else 0 end as SOLID_TUMOR
, case when arthdrg   = 1 then 0 when arth = 1 then 1 else 0 end as RHEUMATOID_ARTHRITIS
, case when coagdrg   = 1 then 0 when coag = 1 then 1 else 0 end as COAGULOPATHY
, case when nutrdrg   = 1
         OR obesedrg  = 1 then 0 when obese = 1 then 1 else 0 end as OBESITY
, case when nutrdrg   = 1 then 0 when wghtloss = 1 then 1 else 0 end as WEIGHT_LOSS
, case when nutrdrg   = 1 then 0 when lytes = 1 then 1 else 0 end as FLUID_ELECTROLYTE
, case when anemdrg   = 1 then 0 when bldloss = 1 then 1 else 0 end as BLOOD_LOSS_ANEMIA
, case when anemdrg   = 1 then 0 when anemdef = 1 then 1 else 0 end as DEFICIENCY_ANEMIAS
, case when alcdrg    = 1 then 0 when alcohol = 1 then 1 else 0 end as ALCOHOL_ABUSE
, case when alcdrg    = 1 then 0 when drug = 1 then 1 else 0 end as DRUG_ABUSE
, case when psydrg    = 1 then 0 when psych = 1 then 1 else 0 end as PSYCHOSES
, case when deprsdrg  = 1 then 0 when depress = 1 then 1 else 0 end as DEPRESSION


from admissions adm
left join eligrp eli
  on adm.hadm_id = eli.hadm_id and adm.subject_id = eli.subject_id
left join drggrp d
  on adm.hadm_id = d.hadm_id and adm.subject_id = d.subject_id
order by adm.hadm_id;
