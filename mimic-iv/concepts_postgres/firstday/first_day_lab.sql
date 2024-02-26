-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS mimiciv_derived.first_day_lab;
CREATE TABLE mimiciv_derived.first_day_lab AS
WITH
  cbc
  AS
  (
    SELECT
      ie.stay_id,
      MIN(hematocrit) AS hematocrit_min,
      AVG(hematocrit) AS hematocrit_mean,
      MAX(hematocrit) AS hematocrit_max,
      MIN(hemoglobin) AS hemoglobin_min,
      AVG(hemoglobin) AS hemoglobin_mean,
      MAX(hemoglobin) AS hemoglobin_max,
      MIN(platelet) AS platelets_min,
      AVG(platelet) AS platelets_mean,
      MAX(platelet) AS platelets_max,
      MIN(wbc) AS wbc_min,
      AVG(wbc) AS wbc_mean,
      MAX(wbc) AS wbc_max
    FROM mimiciv_icu.icustays AS ie
      LEFT JOIN mimiciv_derived.complete_blood_count AS le
      ON le.subject_id = ie.subject_id
        AND le.charttime >= ie.intime - INTERVAL
  
  
  
   '6 HOUR'
    AND le.charttime <= ie.intime + INTERVAL '1 DAY'
  GROUP BY
    ie.stay_id
), chem AS
(
  SELECT
  ie.stay_id,
  MIN(albumin) AS albumin_min,
  AVG(albumin) AS albumin_mean,
  MAX(albumin) AS albumin_max,
  MIN(globulin) AS globulin_min,
  AVG(globulin) AS globulin_mean,
  MAX(globulin) AS globulin_max,
  MIN(total_protein) AS total_protein_min,
  AVG(total_protein) AS total_protein_mean,
  MAX(total_protein) AS total_protein_max,
  MIN(aniongap) AS aniongap_min,
  AVG(aniongap) AS aniongap_mean,
  MAX(aniongap) AS aniongap_max,
  MIN(bicarbonate) AS bicarbonate_min,
  AVG(bicarbonate) AS bicarbonate_mean,
  MAX(bicarbonate) AS bicarbonate_max,
  MIN(bun) AS bun_min,
  AVG(bun) AS bun_mean,
  MAX(bun) AS bun_max,
  MIN(calcium) AS calcium_min,
  AVG(calcium) AS calcium_mean,
  MAX(calcium) AS calcium_max,
  MIN(chloride) AS chloride_min,
  AVG(chloride) AS chloride_mean,
  MAX(chloride) AS chloride_max,
  MIN(creatinine) AS creatinine_min,
  AVG(creatinine) AS creatinine_mean,
  MAX(creatinine) AS creatinine_max,
  MIN(glucose) AS glucose_min,
  AVG(glucose) AS glucose_mean,
  MAX(glucose) AS glucose_max,
  MIN(sodium) AS sodium_min,
  AVG(sodium) AS sodium_mean,
  MAX(sodium) AS sodium_max,
  MIN(potassium) AS potassium_min,
  AVG(potassium) AS potassium_mean,
  MAX(potassium) AS potassium_max
FROM mimiciv_icu.icustays AS ie
  LEFT JOIN mimiciv_derived.chemistry AS le
  ON le.subject_id = ie.subject_id
    AND le.charttime >= ie.intime - INTERVAL
'6 HOUR'
    AND le.charttime <= ie.intime + INTERVAL '1 DAY'
  GROUP BY
    ie.stay_id
), diff AS
(
  SELECT
  ie.stay_id,
  MIN(basophils_abs) AS abs_basophils_min,
  AVG(basophils_abs) AS abs_basophils_mean,
  MAX(basophils_abs) AS abs_basophils_max,
  MIN(eosinophils_abs) AS abs_eosinophils_min,
  AVG(eosinophils_abs) AS abs_eosinophils_mean,
  MAX(eosinophils_abs) AS abs_eosinophils_max,
  MIN(lymphocytes_abs) AS abs_lymphocytes_min,
  AVG(lymphocytes_abs) AS abs_lymphocytes_mean,
  MAX(lymphocytes_abs) AS abs_lymphocytes_max,
  MIN(monocytes_abs) AS abs_monocytes_min,
  AVG(monocytes_abs) AS abs_monocytes_mean,
  MAX(monocytes_abs) AS abs_monocytes_max,
  MIN(neutrophils_abs) AS abs_neutrophils_min,
  AVG(neutrophils_abs) AS abs_neutrophils_mean,
  MAX(neutrophils_abs) AS abs_neutrophils_max,
  MIN(atypical_lymphocytes) AS atyps_min,
  AVG(atypical_lymphocytes) AS atyps_mean,
  MAX(atypical_lymphocytes) AS atyps_max,
  MIN(bands) AS bands_min,
  AVG(bands) AS bands_mean,
  MAX(bands) AS bands_max,
  MIN(immature_granulocytes) AS imm_granulocytes_min,
  AVG(immature_granulocytes) AS imm_granulocytes_mean,
  MAX(immature_granulocytes) AS imm_granulocytes_max,
  MIN(metamyelocytes) AS metas_min,
  AVG(metamyelocytes) AS metas_mean,
  MAX(metamyelocytes) AS metas_max,
  MIN(nrbc) AS nrbc_min,
  AVG(nrbc) AS nrbc_mean,
  MAX(nrbc) AS nrbc_max
FROM mimiciv_icu.icustays AS ie
  LEFT JOIN mimiciv_derived.blood_differential AS le
  ON le.subject_id = ie.subject_id
    AND le.charttime >= ie.intime - INTERVAL
'6 HOUR'
    AND le.charttime <= ie.intime + INTERVAL '1 DAY'
  GROUP BY
    ie.stay_id
), coag AS
(
  SELECT
  ie.stay_id,
  MIN(d_dimer) AS d_dimer_min,
  AVG(d_dimer) AS d_dimer_mean,
  MAX(d_dimer) AS d_dimer_max,
  MIN(fibrinogen) AS fibrinogen_min,
  AVG(fibrinogen) AS fibrinogen_mean,
  MAX(fibrinogen) AS fibrinogen_max,
  MIN(thrombin) AS thrombin_min,
  AVG(thrombin) AS thrombin_mean,
  MAX(thrombin) AS thrombin_max,
  MIN(inr) AS inr_min,
  AVG(inr) AS inr_mean,
  MAX(inr) AS inr_max,
  MIN(pt) AS pt_min,
  AVG(pt) AS pt_mean,
  MAX(pt) AS pt_max,
  MIN(ptt) AS ptt_min,
  AVG(ptt) AS ptt_mean,
  MAX(ptt) AS ptt_max
FROM mimiciv_icu.icustays AS ie
  LEFT JOIN mimiciv_derived.coagulation AS le
  ON le.subject_id = ie.subject_id
    AND le.charttime >= ie.intime - INTERVAL
'6 HOUR'
    AND le.charttime <= ie.intime + INTERVAL '1 DAY'
  GROUP BY
    ie.stay_id
), enz AS
(
  SELECT
  ie.stay_id,
  MIN(alt) AS alt_min,
  AVG(alt) AS alt_mean,
  MAX(alt) AS alt_max,
  MIN(alp) AS alp_min,
  AVG(alp) AS alp_mean,
  MAX(alp) AS alp_max,
  MIN(ast) AS ast_min,
  AVG(ast) AS ast_mean,
  MAX(ast) AS ast_max,
  MIN(amylase) AS amylase_min,
  AVG(amylase) AS amylase_mean,
  MAX(amylase) AS amylase_max,
  MIN(bilirubin_total) AS bilirubin_total_min,
  AVG(bilirubin_total) AS bilirubin_total_mean,
  MAX(bilirubin_total) AS bilirubin_total_max,
  MIN(bilirubin_direct) AS bilirubin_direct_min,
  AVG(bilirubin_direct) AS bilirubin_direct_mean,
  MAX(bilirubin_direct) AS bilirubin_direct_max,
  MIN(bilirubin_indirect) AS bilirubin_indirect_min,
  AVG(bilirubin_indirect) AS bilirubin_indirect_mean,
  MAX(bilirubin_indirect) AS bilirubin_indirect_max,
  MIN(ck_cpk) AS ck_cpk_min,
  AVG(ck_cpk) AS ck_cpk_mean,
  MAX(ck_cpk) AS ck_cpk_max,
  MIN(ck_mb) AS ck_mb_min,
  AVG(ck_mb) AS ck_mb_mean,
  MAX(ck_mb) AS ck_mb_max,
  MIN(ggt) AS ggt_min,
  AVG(ggt) AS ggt_mean,
  MAX(ggt) AS ggt_max,
  MIN(ld_ldh) AS ld_ldh_min,
  AVG(ld_ldh) AS ld_ldh_mean,
  MAX(ld_ldh) AS ld_ldh_max
FROM mimiciv_icu.icustays AS ie
  LEFT JOIN mimiciv_derived.enzyme AS le
  ON le.subject_id = ie.subject_id
    AND le.charttime >= ie.intime - INTERVAL
'6 HOUR'
    AND le.charttime <= ie.intime + INTERVAL '1 DAY'
  GROUP BY
    ie.stay_id
)
SELECT
  ie.subject_id,
  ie.stay_id, /* complete blood count */
  hematocrit_min,
  hematocrit_mean,
  hematocrit_max,
  hemoglobin_min,
  hemoglobin_mean,
  hemoglobin_max,
  platelets_min,
  platelets_mean,
  platelets_max,
  wbc_min,
  wbc_mean,
  wbc_max, /* chemistry */
  albumin_min,
  albumin_mean,
  albumin_max,
  globulin_min,
  globulin_mean,
  globulin_max,
  total_protein_min,
  total_protein_mean,
  total_protein_max,
  aniongap_min,
  aniongap_mean,
  aniongap_max,
  bicarbonate_min,
  bicarbonate_mean,
  bicarbonate_max,
  bun_min,
  bun_mean,
  bun_max,
  calcium_min,
  calcium_mean,
  calcium_max,
  chloride_min,
  chloride_mean,
  chloride_max,
  creatinine_min,
  creatinine_mean,
  creatinine_max,
  glucose_min,
  glucose_mean,
  glucose_max,
  sodium_min,
  sodium_mean,
  sodium_max,
  potassium_min,
  potassium_mean,
  potassium_max, /* blood differential */
  abs_basophils_min,
  abs_basophils_mean,
  abs_basophils_max,
  abs_eosinophils_min,
  abs_eosinophils_mean,
  abs_eosinophils_max,
  abs_lymphocytes_min,
  abs_lymphocytes_mean,
  abs_lymphocytes_max,
  abs_monocytes_min,
  abs_monocytes_mean,
  abs_monocytes_max,
  abs_neutrophils_min,
  abs_neutrophils_mean,
  abs_neutrophils_max,
  atyps_min,
  atyps_mean,
  atyps_max,
  bands_min,
  bands_mean,
  bands_max,
  imm_granulocytes_min,
  imm_granulocytes_mean,
  imm_granulocytes_max,
  metas_min,
  metas_mean,
  metas_max,
  nrbc_min,
  nrbc_mean,
  nrbc_max, /* coagulation */
  d_dimer_min,
  d_dimer_mean,
  d_dimer_max,
  fibrinogen_min,
  fibrinogen_mean,
  fibrinogen_max,
  thrombin_min,
  thrombin_mean,
  thrombin_max,
  inr_min,
  inr_mean,
  inr_max,
  pt_min,
  pt_mean,
  pt_max,
  ptt_min,
  ptt_mean,
  ptt_max, /* enzymes and bilirubin */
  alt_min,
  alt_mean,
  alt_max,
  alp_min,
  alp_mean,
  alp_max,
  ast_min,
  ast_mean,
  ast_max,
  amylase_min,
  amylase_mean,
  amylase_max,
  bilirubin_total_min,
  bilirubin_total_mean,
  bilirubin_total_max,
  bilirubin_direct_min,
  bilirubin_direct_mean,
  bilirubin_direct_max,
  bilirubin_indirect_min,
  bilirubin_indirect_mean,
  bilirubin_indirect_max,
  ck_cpk_min,
  ck_cpk_mean,
  ck_cpk_max,
  ck_mb_min,
  ck_mb_mean,
  ck_mb_max,
  ggt_min,
  ggt_mean,
  ggt_max,
  ld_ldh_min,
  ld_ldh_mean,
  ld_ldh_max
FROM mimiciv_icu.icustays AS ie
  LEFT JOIN cbc
  ON ie.stay_id = cbc.stay_id
  LEFT JOIN chem
  ON ie.stay_id = chem.stay_id
  LEFT JOIN diff
  ON ie.stay_id = diff.stay_id
  LEFT JOIN coag
  ON ie.stay_id = coag.stay_id
  LEFT JOIN enz
  ON ie.stay_id = enz.stay_id