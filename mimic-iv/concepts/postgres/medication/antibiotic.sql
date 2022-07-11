-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS antibiotic; CREATE TABLE antibiotic AS 
with abx as
(
  SELECT DISTINCT
    drug
    , route
    , case
      when lower(drug) like '%adoxa%' then 1
      when lower(drug) like '%ala-tet%' then 1
      when lower(drug) like '%alodox%' then 1
      when lower(drug) like '%amikacin%' then 1
      when lower(drug) like '%amikin%' then 1
      when lower(drug) like '%amoxicill%' then 1
      when lower(drug) like '%amphotericin%' then 1
      when lower(drug) like '%anidulafungin%' then 1
      when lower(drug) like '%ancef%' then 1
      when lower(drug) like '%clavulanate%' then 1
      when lower(drug) like '%ampicillin%' then 1
      when lower(drug) like '%augmentin%' then 1
      when lower(drug) like '%avelox%' then 1
      when lower(drug) like '%avidoxy%' then 1
      when lower(drug) like '%azactam%' then 1
      when lower(drug) like '%azithromycin%' then 1
      when lower(drug) like '%aztreonam%' then 1
      when lower(drug) like '%axetil%' then 1
      when lower(drug) like '%bactocill%' then 1
      when lower(drug) like '%bactrim%' then 1
      when lower(drug) like '%bactroban%' then 1
      when lower(drug) like '%bethkis%' then 1
      when lower(drug) like '%biaxin%' then 1
      when lower(drug) like '%bicillin l-a%' then 1
      when lower(drug) like '%cayston%' then 1
      when lower(drug) like '%cefazolin%' then 1
      when lower(drug) like '%cedax%' then 1
      when lower(drug) like '%cefoxitin%' then 1
      when lower(drug) like '%ceftazidime%' then 1
      when lower(drug) like '%cefaclor%' then 1
      when lower(drug) like '%cefadroxil%' then 1
      when lower(drug) like '%cefdinir%' then 1
      when lower(drug) like '%cefditoren%' then 1
      when lower(drug) like '%cefepime%' then 1
      when lower(drug) like '%cefotan%' then 1
      when lower(drug) like '%cefotetan%' then 1
      when lower(drug) like '%cefotaxime%' then 1
      when lower(drug) like '%ceftaroline%' then 1
      when lower(drug) like '%cefpodoxime%' then 1
      when lower(drug) like '%cefpirome%' then 1
      when lower(drug) like '%cefprozil%' then 1
      when lower(drug) like '%ceftibuten%' then 1
      when lower(drug) like '%ceftin%' then 1
      when lower(drug) like '%ceftriaxone%' then 1
      when lower(drug) like '%cefuroxime%' then 1
      when lower(drug) like '%cephalexin%' then 1
      when lower(drug) like '%cephalothin%' then 1
      when lower(drug) like '%cephapririn%' then 1
      when lower(drug) like '%chloramphenicol%' then 1
      when lower(drug) like '%cipro%' then 1
      when lower(drug) like '%ciprofloxacin%' then 1
      when lower(drug) like '%claforan%' then 1
      when lower(drug) like '%clarithromycin%' then 1
      when lower(drug) like '%cleocin%' then 1
      when lower(drug) like '%clindamycin%' then 1
      when lower(drug) like '%cubicin%' then 1
      when lower(drug) like '%dicloxacillin%' then 1
      when lower(drug) like '%dirithromycin%' then 1
      when lower(drug) like '%doryx%' then 1
      when lower(drug) like '%doxycy%' then 1
      when lower(drug) like '%duricef%' then 1
      when lower(drug) like '%dynacin%' then 1
      when lower(drug) like '%ery-tab%' then 1
      when lower(drug) like '%eryped%' then 1
      when lower(drug) like '%eryc%' then 1
      when lower(drug) like '%erythrocin%' then 1
      when lower(drug) like '%erythromycin%' then 1
      when lower(drug) like '%factive%' then 1
      when lower(drug) like '%flagyl%' then 1
      when lower(drug) like '%fortaz%' then 1
      when lower(drug) like '%furadantin%' then 1
      when lower(drug) like '%garamycin%' then 1
      when lower(drug) like '%gentamicin%' then 1
      when lower(drug) like '%kanamycin%' then 1
      when lower(drug) like '%keflex%' then 1
      when lower(drug) like '%kefzol%' then 1
      when lower(drug) like '%ketek%' then 1
      when lower(drug) like '%levaquin%' then 1
      when lower(drug) like '%levofloxacin%' then 1
      when lower(drug) like '%lincocin%' then 1
      when lower(drug) like '%linezolid%' then 1
      when lower(drug) like '%macrobid%' then 1
      when lower(drug) like '%macrodantin%' then 1
      when lower(drug) like '%maxipime%' then 1
      when lower(drug) like '%mefoxin%' then 1
      when lower(drug) like '%metronidazole%' then 1
      when lower(drug) like '%meropenem%' then 1
      when lower(drug) like '%methicillin%' then 1
      when lower(drug) like '%minocin%' then 1
      when lower(drug) like '%minocycline%' then 1
      when lower(drug) like '%monodox%' then 1
      when lower(drug) like '%monurol%' then 1
      when lower(drug) like '%morgidox%' then 1
      when lower(drug) like '%moxatag%' then 1
      when lower(drug) like '%moxifloxacin%' then 1
      when lower(drug) like '%mupirocin%' then 1
      when lower(drug) like '%myrac%' then 1
      when lower(drug) like '%nafcillin%' then 1
      when lower(drug) like '%neomycin%' then 1
      when lower(drug) like '%nicazel doxy 30%' then 1
      when lower(drug) like '%nitrofurantoin%' then 1
      when lower(drug) like '%norfloxacin%' then 1
      when lower(drug) like '%noroxin%' then 1
      when lower(drug) like '%ocudox%' then 1
      when lower(drug) like '%ofloxacin%' then 1
      when lower(drug) like '%omnicef%' then 1
      when lower(drug) like '%oracea%' then 1
      when lower(drug) like '%oraxyl%' then 1
      when lower(drug) like '%oxacillin%' then 1
      when lower(drug) like '%pc pen vk%' then 1
      when lower(drug) like '%pce dispertab%' then 1
      when lower(drug) like '%panixine%' then 1
      when lower(drug) like '%pediazole%' then 1
      when lower(drug) like '%penicillin%' then 1
      when lower(drug) like '%periostat%' then 1
      when lower(drug) like '%pfizerpen%' then 1
      when lower(drug) like '%piperacillin%' then 1
      when lower(drug) like '%tazobactam%' then 1
      when lower(drug) like '%primsol%' then 1
      when lower(drug) like '%proquin%' then 1
      when lower(drug) like '%raniclor%' then 1
      when lower(drug) like '%rifadin%' then 1
      when lower(drug) like '%rifampin%' then 1
      when lower(drug) like '%rocephin%' then 1
      when lower(drug) like '%smz-tmp%' then 1
      when lower(drug) like '%septra%' then 1
      when lower(drug) like '%septra ds%' then 1
      when lower(drug) like '%septra%' then 1
      when lower(drug) like '%solodyn%' then 1
      when lower(drug) like '%spectracef%' then 1
      when lower(drug) like '%streptomycin%' then 1
      when lower(drug) like '%sulfadiazine%' then 1
      when lower(drug) like '%sulfamethoxazole%' then 1
      when lower(drug) like '%trimethoprim%' then 1
      when lower(drug) like '%sulfatrim%' then 1
      when lower(drug) like '%sulfisoxazole%' then 1
      when lower(drug) like '%suprax%' then 1
      when lower(drug) like '%synercid%' then 1
      when lower(drug) like '%tazicef%' then 1
      when lower(drug) like '%tetracycline%' then 1
      when lower(drug) like '%timentin%' then 1
      when lower(drug) like '%tobramycin%' then 1
      when lower(drug) like '%trimethoprim%' then 1
      when lower(drug) like '%unasyn%' then 1
      when lower(drug) like '%vancocin%' then 1
      when lower(drug) like '%vancomycin%' then 1
      when lower(drug) like '%vantin%' then 1
      when lower(drug) like '%vibativ%' then 1
      when lower(drug) like '%vibra-tabs%' then 1
      when lower(drug) like '%vibramycin%' then 1
      when lower(drug) like '%zinacef%' then 1
      when lower(drug) like '%zithromax%' then 1
      when lower(drug) like '%zosyn%' then 1
      when lower(drug) like '%zyvox%' then 1
    else 0
    end as antibiotic
  from mimiciv_hosp.prescriptions
  -- excludes vials/syringe/normal saline, etc
  where drug_type not in ('BASE')
  -- we exclude routes via the eye, ears, or topically
  and route not in ('OU','OS','OD','AU','AS','AD', 'TP')
  and lower(route) not like '%ear%'
  and lower(route) not like '%eye%'
  -- we exclude certain types of antibiotics: topical creams, gels, desens, etc
  and lower(drug) not like '%cream%'
  and lower(drug) not like '%desensitization%'
  and lower(drug) not like '%ophth oint%'
  and lower(drug) not like '%gel%'
  -- other routes not sure about...
  -- for sure keep: ('IV','PO','PO/NG','ORAL', 'IV DRIP', 'IV BOLUS')
  -- ? VT, PB, PR, PL, NS, NG, NEB, NAS, LOCK, J TUBE, IVT
  -- ? IT, IRR, IP, IO, INHALATION, IN, IM
  -- ? IJ, IH, G TUBE, DIALYS
  -- ?? enemas??
)
select 
pr.subject_id, pr.hadm_id
, ie.stay_id
, pr.drug as antibiotic
, pr.route
, pr.starttime
, pr.stoptime
from mimiciv_hosp.prescriptions pr
-- inner join to subselect to only antibiotic prescriptions
inner join abx
    on pr.drug = abx.drug
    -- route is never NULL for antibiotics
    -- only ~4000 null rows in prescriptions total.
    AND pr.route = abx.route
-- add in stay_id as we use this table for sepsis-3
LEFT JOIN mimiciv_icu.icustays ie
    ON pr.hadm_id = ie.hadm_id
    AND pr.starttime >= ie.intime
    AND pr.starttime < ie.outtime
WHERE abx.antibiotic = 1
;