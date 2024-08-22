-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.antibiotic; CREATE TABLE mimiciv_derived.antibiotic AS
WITH abx AS (
  SELECT DISTINCT
    drug,
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
      WHEN LOWER(drug) LIKE '%amoxicill%'
      THEN 1
      WHEN LOWER(drug) LIKE '%amphotericin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%anidulafungin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ancef%'
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
      WHEN LOWER(drug) LIKE '%bactroban%'
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
      WHEN LOWER(drug) LIKE '%cefotan%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefotetan%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefotaxime%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ceftaroline%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefpodoxime%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefpirome%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefprozil%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ceftibuten%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ceftin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ceftriaxone%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cefuroxime%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cephalexin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cephalothin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%cephapririn%'
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
      WHEN LOWER(drug) LIKE '%dirithromycin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%doryx%'
      THEN 1
      WHEN LOWER(drug) LIKE '%doxycy%'
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
      WHEN LOWER(drug) LIKE '%kefzol%'
      THEN 1
      WHEN LOWER(drug) LIKE '%ketek%'
      THEN 1
      WHEN LOWER(drug) LIKE '%levaquin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%levofloxacin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%lincocin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%linezolid%'
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
      WHEN LOWER(drug) LIKE '%meropenem%'
      THEN 1
      WHEN LOWER(drug) LIKE '%methicillin%'
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
      WHEN LOWER(drug) LIKE '%mupirocin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%myrac%'
      THEN 1
      WHEN LOWER(drug) LIKE '%nafcillin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%neomycin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%nicazel doxy 30%'
      THEN 1
      WHEN LOWER(drug) LIKE '%nitrofurantoin%'
      THEN 1
      WHEN LOWER(drug) LIKE '%norfloxacin%'
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
      WHEN LOWER(drug) LIKE '%streptomycin%'
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
      WHEN LOWER(drug) LIKE '%zosyn%'
      THEN 1
      WHEN LOWER(drug) LIKE '%zyvox%'
      THEN 1
      ELSE 0
    END AS antibiotic
  FROM mimiciv_hosp.prescriptions
  WHERE
    NOT drug_type IN ('BASE')
    AND NOT route IN ('OU', 'OS', 'OD', 'AU', 'AS', 'AD', 'TP')
    AND NOT LOWER(route) LIKE '%ear%'
    AND NOT LOWER(route) LIKE '%eye%'
    AND NOT LOWER(drug) LIKE '%cream%'
    AND NOT LOWER(drug) LIKE '%desensitization%'
    AND NOT LOWER(drug) LIKE '%ophth oint%'
    AND NOT LOWER(drug) LIKE '%gel%'
)
SELECT
  pr.subject_id,
  pr.hadm_id,
  ie.stay_id,
  pr.drug AS antibiotic,
  pr.route,
  pr.starttime,
  pr.stoptime
FROM mimiciv_hosp.prescriptions AS pr
INNER JOIN abx
  ON pr.drug = abx.drug AND pr.route = abx.route
LEFT JOIN mimiciv_icu.icustays AS ie
  ON pr.hadm_id = ie.hadm_id
  AND pr.starttime >= ie.intime
  AND pr.starttime < ie.outtime
WHERE
  abx.antibiotic = 1