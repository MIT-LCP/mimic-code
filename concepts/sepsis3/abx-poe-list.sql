DROP TABLE IF EXISTS `physionet-data.mimic_derived.abx_poe_list`;
CREATE TABLE `physionet-data.mimic_derived.abx_poe_list` AS 
with t1 as
(
  select
    drug
    , route
    , case
      when lower(drug) like '%' || lower('adoxa') || '%' then 1
      when lower(drug) like '%' || lower('ala-tet') || '%' then 1
      when lower(drug) like '%' || lower('alodox') || '%' then 1
      when lower(drug) like '%' || lower('amikacin') || '%' then 1
      when lower(drug) like '%' || lower('amikin') || '%' then 1
      when lower(drug) like '%' || lower('amoxicillin') || '%' then 1
      when lower(drug) like '%' || lower('amoxicillin%clavulanate') || '%' then 1
      when lower(drug) like '%' || lower('clavulanate') || '%' then 1
      when lower(drug) like '%' || lower('ampicillin') || '%' then 1
      when lower(drug) like '%' || lower('augmentin') || '%' then 1
      when lower(drug) like '%' || lower('avelox') || '%' then 1
      when lower(drug) like '%' || lower('avidoxy') || '%' then 1
      when lower(drug) like '%' || lower('azactam') || '%' then 1
      when lower(drug) like '%' || lower('azithromycin') || '%' then 1
      when lower(drug) like '%' || lower('aztreonam') || '%' then 1
      when lower(drug) like '%' || lower('axetil') || '%' then 1
      when lower(drug) like '%' || lower('bactocill') || '%' then 1
      when lower(drug) like '%' || lower('bactrim') || '%' then 1
      when lower(drug) like '%' || lower('bethkis') || '%' then 1
      when lower(drug) like '%' || lower('biaxin') || '%' then 1
      when lower(drug) like '%' || lower('bicillin l-a') || '%' then 1
      when lower(drug) like '%' || lower('cayston') || '%' then 1
      when lower(drug) like '%' || lower('cefazolin') || '%' then 1
      when lower(drug) like '%' || lower('cedax') || '%' then 1
      when lower(drug) like '%' || lower('cefoxitin') || '%' then 1
      when lower(drug) like '%' || lower('ceftazidime') || '%' then 1
      when lower(drug) like '%' || lower('cefaclor') || '%' then 1
      when lower(drug) like '%' || lower('cefadroxil') || '%' then 1
      when lower(drug) like '%' || lower('cefdinir') || '%' then 1
      when lower(drug) like '%' || lower('cefditoren') || '%' then 1
      when lower(drug) like '%' || lower('cefepime') || '%' then 1
      when lower(drug) like '%' || lower('cefotetan') || '%' then 1
      when lower(drug) like '%' || lower('cefotaxime') || '%' then 1
      when lower(drug) like '%' || lower('cefpodoxime') || '%' then 1
      when lower(drug) like '%' || lower('cefprozil') || '%' then 1
      when lower(drug) like '%' || lower('ceftibuten') || '%' then 1
      when lower(drug) like '%' || lower('ceftin') || '%' then 1
      when lower(drug) like '%' || lower('cefuroxime ') || '%' then 1
      when lower(drug) like '%' || lower('cefuroxime') || '%' then 1
      when lower(drug) like '%' || lower('cephalexin') || '%' then 1
      when lower(drug) like '%' || lower('chloramphenicol') || '%' then 1
      when lower(drug) like '%' || lower('cipro') || '%' then 1
      when lower(drug) like '%' || lower('ciprofloxacin') || '%' then 1
      when lower(drug) like '%' || lower('claforan') || '%' then 1
      when lower(drug) like '%' || lower('clarithromycin') || '%' then 1
      when lower(drug) like '%' || lower('cleocin') || '%' then 1
      when lower(drug) like '%' || lower('clindamycin') || '%' then 1
      when lower(drug) like '%' || lower('cubicin') || '%' then 1
      when lower(drug) like '%' || lower('dicloxacillin') || '%' then 1
      when lower(drug) like '%' || lower('doryx') || '%' then 1
      when lower(drug) like '%' || lower('doxycycline') || '%' then 1
      when lower(drug) like '%' || lower('duricef') || '%' then 1
      when lower(drug) like '%' || lower('dynacin') || '%' then 1
      when lower(drug) like '%' || lower('ery-tab') || '%' then 1
      when lower(drug) like '%' || lower('eryped') || '%' then 1
      when lower(drug) like '%' || lower('eryc') || '%' then 1
      when lower(drug) like '%' || lower('erythrocin') || '%' then 1
      when lower(drug) like '%' || lower('erythromycin') || '%' then 1
      when lower(drug) like '%' || lower('factive') || '%' then 1
      when lower(drug) like '%' || lower('flagyl') || '%' then 1
      when lower(drug) like '%' || lower('fortaz') || '%' then 1
      when lower(drug) like '%' || lower('furadantin') || '%' then 1
      when lower(drug) like '%' || lower('garamycin') || '%' then 1
      when lower(drug) like '%' || lower('gentamicin') || '%' then 1
      when lower(drug) like '%' || lower('kanamycin') || '%' then 1
      when lower(drug) like '%' || lower('keflex') || '%' then 1
      when lower(drug) like '%' || lower('ketek') || '%' then 1
      when lower(drug) like '%' || lower('levaquin') || '%' then 1
      when lower(drug) like '%' || lower('levofloxacin') || '%' then 1
      when lower(drug) like '%' || lower('lincocin') || '%' then 1
      when lower(drug) like '%' || lower('macrobid') || '%' then 1
      when lower(drug) like '%' || lower('macrodantin') || '%' then 1
      when lower(drug) like '%' || lower('maxipime') || '%' then 1
      when lower(drug) like '%' || lower('mefoxin') || '%' then 1
      when lower(drug) like '%' || lower('metronidazole') || '%' then 1
      when lower(drug) like '%' || lower('minocin') || '%' then 1
      when lower(drug) like '%' || lower('minocycline') || '%' then 1
      when lower(drug) like '%' || lower('monodox') || '%' then 1
      when lower(drug) like '%' || lower('monurol') || '%' then 1
      when lower(drug) like '%' || lower('morgidox') || '%' then 1
      when lower(drug) like '%' || lower('moxatag') || '%' then 1
      when lower(drug) like '%' || lower('moxifloxacin') || '%' then 1
      when lower(drug) like '%' || lower('myrac') || '%' then 1
      when lower(drug) like '%' || lower('nafcillin sodium') || '%' then 1
      when lower(drug) like '%' || lower('nicazel doxy 30') || '%' then 1
      when lower(drug) like '%' || lower('nitrofurantoin') || '%' then 1
      when lower(drug) like '%' || lower('noroxin') || '%' then 1
      when lower(drug) like '%' || lower('ocudox') || '%' then 1
      when lower(drug) like '%' || lower('ofloxacin') || '%' then 1
      when lower(drug) like '%' || lower('omnicef') || '%' then 1
      when lower(drug) like '%' || lower('oracea') || '%' then 1
      when lower(drug) like '%' || lower('oraxyl') || '%' then 1
      when lower(drug) like '%' || lower('oxacillin') || '%' then 1
      when lower(drug) like '%' || lower('pc pen vk') || '%' then 1
      when lower(drug) like '%' || lower('pce dispertab') || '%' then 1
      when lower(drug) like '%' || lower('panixine') || '%' then 1
      when lower(drug) like '%' || lower('pediazole') || '%' then 1
      when lower(drug) like '%' || lower('penicillin') || '%' then 1
      when lower(drug) like '%' || lower('periostat') || '%' then 1
      when lower(drug) like '%' || lower('pfizerpen') || '%' then 1
      when lower(drug) like '%' || lower('piperacillin') || '%' then 1
      when lower(drug) like '%' || lower('tazobactam') || '%' then 1
      when lower(drug) like '%' || lower('primsol') || '%' then 1
      when lower(drug) like '%' || lower('proquin') || '%' then 1
      when lower(drug) like '%' || lower('raniclor') || '%' then 1
      when lower(drug) like '%' || lower('rifadin') || '%' then 1
      when lower(drug) like '%' || lower('rifampin') || '%' then 1
      when lower(drug) like '%' || lower('rocephin') || '%' then 1
      when lower(drug) like '%' || lower('smz-tmp') || '%' then 1
      when lower(drug) like '%' || lower('septra') || '%' then 1
      when lower(drug) like '%' || lower('septra ds') || '%' then 1
      when lower(drug) like '%' || lower('septra') || '%' then 1
      when lower(drug) like '%' || lower('solodyn') || '%' then 1
      when lower(drug) like '%' || lower('spectracef') || '%' then 1
      when lower(drug) like '%' || lower('streptomycin sulfate') || '%' then 1
      when lower(drug) like '%' || lower('sulfadiazine') || '%' then 1
      when lower(drug) like '%' || lower('sulfamethoxazole') || '%' then 1
      when lower(drug) like '%' || lower('trimethoprim') || '%' then 1
      when lower(drug) like '%' || lower('sulfatrim') || '%' then 1
      when lower(drug) like '%' || lower('sulfisoxazole') || '%' then 1
      when lower(drug) like '%' || lower('suprax') || '%' then 1
      when lower(drug) like '%' || lower('synercid') || '%' then 1
      when lower(drug) like '%' || lower('tazicef') || '%' then 1
      when lower(drug) like '%' || lower('tetracycline') || '%' then 1
      when lower(drug) like '%' || lower('timentin') || '%' then 1
      when lower(drug) like '%' || lower('tobi') || '%' then 1
      when lower(drug) like '%' || lower('tobramycin') || '%' then 1
      when lower(drug) like '%' || lower('trimethoprim') || '%' then 1
      when lower(drug) like '%' || lower('unasyn') || '%' then 1
      when lower(drug) like '%' || lower('vancocin') || '%' then 1
      when lower(drug) like '%' || lower('vancomycin') || '%' then 1
      when lower(drug) like '%' || lower('vantin') || '%' then 1
      when lower(drug) like '%' || lower('vibativ') || '%' then 1
      when lower(drug) like '%' || lower('vibra-tabs') || '%' then 1
      when lower(drug) like '%' || lower('vibramycin') || '%' then 1
      when lower(drug) like '%' || lower('zinacef') || '%' then 1
      when lower(drug) like '%' || lower('zithromax') || '%' then 1
      when lower(drug) like '%' || lower('zmax') || '%' then 1
      when lower(drug) like '%' || lower('zosyn') || '%' then 1
      when lower(drug) like '%' || lower('zyvox') || '%' then 1
    else 0
    end as antibiotic
  from `physionet-data.mimic_hosp.prescriptions`
  where drug_type in ('MAIN','ADDITIVE')
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
  drug 
  , count(*) as numobs
from t1
where antibiotic = 1
group by drug
order by numobs desc;