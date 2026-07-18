-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciii_derived.abx_prescriptions_list; CREATE TABLE mimiciii_derived.abx_prescriptions_list AS
WITH t1 AS (
  SELECT
    drug,
    drug_name_generic,
    route,
    CASE
      WHEN LOWER(drug) LIKE '%adoxa%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ala-tet%'
      THEN 1
      WHEN LOWER(drug) LIKE '%alodox%'
      THEN 1
      WHEN LOWER(drug) LIKE '%amikacin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%amikin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%amoxicillin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%amoxicillin%clavulanate%'
      THEN 1
      WHEN LOWER(drug) LIKE '%clavulanate%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ampicillin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%augmentin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%avelox%'
      THEN 1
      WHEN LOWER(drug) LIKE '%avidoxy%'
      THEN 1
      WHEN LOWER(drug) LIKE '%azactam%'
      THEN 1
      WHEN LOWER(drug) LIKE '%azithromycin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%aztreonam%'
      THEN 1
      WHEN LOWER(drug) LIKE '%axetil%'
      THEN 1
      WHEN LOWER(drug) LIKE '%bactocill%'
      THEN 1
      WHEN LOWER(drug) LIKE '%bactrim%'
      THEN 1
      WHEN LOWER(drug) LIKE '%bethkis%'
      THEN 1
      WHEN LOWER(drug) LIKE '%biaxin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%bicillin l-a%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cayston%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefazolin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cedax%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefoxitin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ceftazidime%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefaclor%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefadroxil%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefdinir%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefditoren%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefepime%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefotetan%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefotaxime%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefpodoxime%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefprozil%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ceftibuten%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ceftin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefuroxime %'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefuroxime%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cephalexin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%chloramphenicol%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cipro%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ciprofloxacin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%claforan%'
      THEN 1
      WHEN LOWER(drug) LIKE '%clarithromycin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cleocin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%clindamycin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cubicin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%dicloxacillin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%doryx%'
      THEN 1
      WHEN LOWER(drug) LIKE '%doxycycline%'
      THEN 1
      WHEN LOWER(drug) LIKE '%duricef%'
      THEN 1
      WHEN LOWER(drug) LIKE '%dynacin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ery-tab%'
      THEN 1
      WHEN LOWER(drug) LIKE '%eryped%'
      THEN 1
      WHEN LOWER(drug) LIKE '%eryc%'
      THEN 1
      WHEN LOWER(drug) LIKE '%erythrocin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%erythromycin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%factive%'
      THEN 1
      WHEN LOWER(drug) LIKE '%flagyl%'
      THEN 1
      WHEN LOWER(drug) LIKE '%fortaz%'
      THEN 1
      WHEN LOWER(drug) LIKE '%furadantin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%garamycin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%gentamicin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%kanamycin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%keflex%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ketek%'
      THEN 1
      WHEN LOWER(drug) LIKE '%levaquin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%levofloxacin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%lincocin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%macrobid%'
      THEN 1
      WHEN LOWER(drug) LIKE '%macrodantin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%maxipime%'
      THEN 1
      WHEN LOWER(drug) LIKE '%mefoxin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%metronidazole%'
      THEN 1
      WHEN LOWER(drug) LIKE '%minocin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%minocycline%'
      THEN 1
      WHEN LOWER(drug) LIKE '%monodox%'
      THEN 1
      WHEN LOWER(drug) LIKE '%monurol%'
      THEN 1
      WHEN LOWER(drug) LIKE '%morgidox%'
      THEN 1
      WHEN LOWER(drug) LIKE '%moxatag%'
      THEN 1
      WHEN LOWER(drug) LIKE '%moxifloxacin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%myrac%'
      THEN 1
      WHEN LOWER(drug) LIKE '%nafcillin sodium%'
      THEN 1
      WHEN LOWER(drug) LIKE '%nicazel doxy 30%'
      THEN 1
      WHEN LOWER(drug) LIKE '%nitrofurantoin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%noroxin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ocudox%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ofloxacin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%omnicef%'
      THEN 1
      WHEN LOWER(drug) LIKE '%oracea%'
      THEN 1
      WHEN LOWER(drug) LIKE '%oraxyl%'
      THEN 1
      WHEN LOWER(drug) LIKE '%oxacillin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%pc pen vk%'
      THEN 1
      WHEN LOWER(drug) LIKE '%pce dispertab%'
      THEN 1
      WHEN LOWER(drug) LIKE '%panixine%'
      THEN 1
      WHEN LOWER(drug) LIKE '%pediazole%'
      THEN 1
      WHEN LOWER(drug) LIKE '%penicillin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%periostat%'
      THEN 1
      WHEN LOWER(drug) LIKE '%pfizerpen%'
      THEN 1
      WHEN LOWER(drug) LIKE '%piperacillin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%tazobactam%'
      THEN 1
      WHEN LOWER(drug) LIKE '%primsol%'
      THEN 1
      WHEN LOWER(drug) LIKE '%proquin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%raniclor%'
      THEN 1
      WHEN LOWER(drug) LIKE '%rifadin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%rifampin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%rocephin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%smz-tmp%'
      THEN 1
      WHEN LOWER(drug) LIKE '%septra%'
      THEN 1
      WHEN LOWER(drug) LIKE '%septra ds%'
      THEN 1
      WHEN LOWER(drug) LIKE '%septra%'
      THEN 1
      WHEN LOWER(drug) LIKE '%solodyn%'
      THEN 1
      WHEN LOWER(drug) LIKE '%spectracef%'
      THEN 1
      WHEN LOWER(drug) LIKE '%streptomycin sulfate%'
      THEN 1
      WHEN LOWER(drug) LIKE '%sulfadiazine%'
      THEN 1
      WHEN LOWER(drug) LIKE '%sulfamethoxazole%'
      THEN 1
      WHEN LOWER(drug) LIKE '%trimethoprim%'
      THEN 1
      WHEN LOWER(drug) LIKE '%sulfatrim%'
      THEN 1
      WHEN LOWER(drug) LIKE '%sulfisoxazole%'
      THEN 1
      WHEN LOWER(drug) LIKE '%suprax%'
      THEN 1
      WHEN LOWER(drug) LIKE '%synercid%'
      THEN 1
      WHEN LOWER(drug) LIKE '%tazicef%'
      THEN 1
      WHEN LOWER(drug) LIKE '%tetracycline%'
      THEN 1
      WHEN LOWER(drug) LIKE '%timentin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%tobi%'
      THEN 1
      WHEN LOWER(drug) LIKE '%tobramycin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%trimethoprim%'
      THEN 1
      WHEN LOWER(drug) LIKE '%unasyn%'
      THEN 1
      WHEN LOWER(drug) LIKE '%vancocin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%vancomycin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%vantin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%vibativ%'
      THEN 1
      WHEN LOWER(drug) LIKE '%vibra-tabs%'
      THEN 1
      WHEN LOWER(drug) LIKE '%vibramycin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%zinacef%'
      THEN 1
      WHEN LOWER(drug) LIKE '%zithromax%'
      THEN 1
      WHEN LOWER(drug) LIKE '%zmax%'
      THEN 1
      WHEN LOWER(drug) LIKE '%zosyn%'
      THEN 1
      WHEN LOWER(drug) LIKE '%zyvox%'
      THEN 1
      ELSE 0
    END AS antibiotic
  FROM mimiciii.prescriptions
  WHERE
    drug_type IN ('MAIN', 'ADDITIVE')
    AND NOT route IN ('OU', 'OS', 'OD', 'AU', 'AS', 'AD', 'TP')
    AND LOWER(route) NOT LIKE '%ear%'
    AND LOWER(route) NOT LIKE '%eye%'
    AND LOWER(drug) NOT LIKE '%cream%'
    AND LOWER(drug) NOT LIKE '%desensitization%'
    AND LOWER(drug) NOT LIKE '%ophth oint%'
    AND LOWER(drug) NOT LIKE '%gel%'
)
SELECT
  drug,
  COUNT(*) AS numobs
FROM t1
WHERE
  antibiotic = 1
GROUP BY
  drug
ORDER BY
  numobs DESC