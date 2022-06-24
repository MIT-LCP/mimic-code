WITH cbc AS
(
    SELECT
    ie.stay_id
    , MIN(hematocrit) as hematocrit_min
    , MAX(hematocrit) as hematocrit_max
    , MIN(hemoglobin) as hemoglobin_min
    , MAX(hemoglobin) as hemoglobin_max
    , MIN(platelet) as platelets_min
    , MAX(platelet) as platelets_max
    , MIN(wbc) as wbc_min
    , MAX(wbc) as wbc_max
    FROM `physionet-data.mimiciv_icu.icustays` ie
    LEFT JOIN `physionet-data.mimiciv_derived.complete_blood_count` le
        ON le.subject_id = ie.subject_id
        AND le.charttime >= DATETIME_SUB(ie.intime, INTERVAL '6' HOUR)
        AND le.charttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
    GROUP BY ie.stay_id
)
, chem AS
(
    SELECT
    ie.stay_id
    , MIN(albumin) AS albumin_min, MAX(albumin) AS albumin_max
    , MIN(globulin) AS globulin_min, MAX(globulin) AS globulin_max
    , MIN(total_protein) AS total_protein_min, MAX(total_protein) AS total_protein_max
    , MIN(aniongap) AS aniongap_min, MAX(aniongap) AS aniongap_max
    , MIN(bicarbonate) AS bicarbonate_min, MAX(bicarbonate) AS bicarbonate_max
    , MIN(bun) AS bun_min, MAX(bun) AS bun_max
    , MIN(calcium) AS calcium_min, MAX(calcium) AS calcium_max
    , MIN(chloride) AS chloride_min, MAX(chloride) AS chloride_max
    , MIN(creatinine) AS creatinine_min, MAX(creatinine) AS creatinine_max
    , MIN(glucose) AS glucose_min, MAX(glucose) AS glucose_max
    , MIN(sodium) AS sodium_min, MAX(sodium) AS sodium_max
    , MIN(potassium) AS potassium_min, MAX(potassium) AS potassium_max
    FROM `physionet-data.mimiciv_icu.icustays` ie
    LEFT JOIN `physionet-data.mimiciv_derived.chemistry` le
        ON le.subject_id = ie.subject_id
        AND le.charttime >= DATETIME_SUB(ie.intime, INTERVAL '6' HOUR)
        AND le.charttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
    GROUP BY ie.stay_id
)
, diff AS
(
    SELECT
    ie.stay_id
    , MIN(basophils_abs) AS abs_basophils_min, MAX(basophils_abs) AS abs_basophils_max
    , MIN(eosinophils_abs) AS abs_eosinophils_min, MAX(eosinophils_abs) AS abs_eosinophils_max
    , MIN(lymphocytes_abs) AS abs_lymphocytes_min, MAX(lymphocytes_abs) AS abs_lymphocytes_max
    , MIN(monocytes_abs) AS abs_monocytes_min, MAX(monocytes_abs) AS abs_monocytes_max
    , MIN(neutrophils_abs) AS abs_neutrophils_min, MAX(neutrophils_abs) AS abs_neutrophils_max
    , MIN(atypical_lymphocytes) AS atyps_min, MAX(atypical_lymphocytes) AS atyps_max
    , MIN(bands) AS bands_min, MAX(bands) AS bands_max
    , MIN(immature_granulocytes) AS imm_granulocytes_min, MAX(immature_granulocytes) AS imm_granulocytes_max
    , MIN(metamyelocytes) AS metas_min, MAX(metamyelocytes) AS metas_max
    , MIN(nrbc) AS nrbc_min, MAX(nrbc) AS nrbc_max
    FROM `physionet-data.mimiciv_icu.icustays` ie
    LEFT JOIN `physionet-data.mimiciv_derived.blood_differential` le
        ON le.subject_id = ie.subject_id
        AND le.charttime >= DATETIME_SUB(ie.intime, INTERVAL '6' HOUR)
        AND le.charttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
    GROUP BY ie.stay_id
)
, coag AS
(
    SELECT
    ie.stay_id
    , MIN(d_dimer) AS d_dimer_min, MAX(d_dimer) AS d_dimer_max
    , MIN(fibrinogen) AS fibrinogen_min, MAX(fibrinogen) AS fibrinogen_max
    , MIN(thrombin) AS thrombin_min, MAX(thrombin) AS thrombin_max
    , MIN(inr) AS inr_min, MAX(inr) AS inr_max
    , MIN(pt) AS pt_min, MAX(pt) AS pt_max
    , MIN(ptt) AS ptt_min, MAX(ptt) AS ptt_max
    FROM `physionet-data.mimiciv_icu.icustays` ie
    LEFT JOIN `physionet-data.mimiciv_derived.coagulation` le
        ON le.subject_id = ie.subject_id
        AND le.charttime >= DATETIME_SUB(ie.intime, INTERVAL '6' HOUR)
        AND le.charttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
    GROUP BY ie.stay_id
)
, enz AS
(
    SELECT
    ie.stay_id

    , MIN(alt) AS alt_min, MAX(alt) AS alt_max
    , MIN(alp) AS alp_min, MAX(alp) AS alp_max
    , MIN(ast) AS ast_min, MAX(ast) AS ast_max
    , MIN(amylase) AS amylase_min, MAX(amylase) AS amylase_max
    , MIN(bilirubin_total) AS bilirubin_total_min, MAX(bilirubin_total) AS bilirubin_total_max
    , MIN(bilirubin_direct) AS bilirubin_direct_min, MAX(bilirubin_direct) AS bilirubin_direct_max
    , MIN(bilirubin_indirect) AS bilirubin_indirect_min, MAX(bilirubin_indirect) AS bilirubin_indirect_max
    , MIN(ck_cpk) AS ck_cpk_min, MAX(ck_cpk) AS ck_cpk_max
    , MIN(ck_mb) AS ck_mb_min, MAX(ck_mb) AS ck_mb_max
    , MIN(ggt) AS ggt_min, MAX(ggt) AS ggt_max
    , MIN(ld_ldh) AS ld_ldh_min, MAX(ld_ldh) AS ld_ldh_max
    FROM `physionet-data.mimiciv_icu.icustays` ie
    LEFT JOIN `physionet-data.mimiciv_derived.enzyme` le
        ON le.subject_id = ie.subject_id
        AND le.charttime >= DATETIME_SUB(ie.intime, INTERVAL '6' HOUR)
        AND le.charttime <= DATETIME_ADD(ie.intime, INTERVAL '1' DAY)
    GROUP BY ie.stay_id
)
SELECT
ie.subject_id
, ie.stay_id
-- complete blood count
, hematocrit_min, hematocrit_max
, hemoglobin_min, hemoglobin_max
, platelets_min, platelets_max
, wbc_min, wbc_max
-- chemistry
, albumin_min, albumin_max
, globulin_min, globulin_max
, total_protein_min, total_protein_max
, aniongap_min, aniongap_max
, bicarbonate_min, bicarbonate_max
, bun_min, bun_max
, calcium_min, calcium_max
, chloride_min, chloride_max
, creatinine_min, creatinine_max
, glucose_min, glucose_max
, sodium_min, sodium_max
, potassium_min, potassium_max
-- blood differential
, abs_basophils_min, abs_basophils_max
, abs_eosinophils_min, abs_eosinophils_max
, abs_lymphocytes_min, abs_lymphocytes_max
, abs_monocytes_min, abs_monocytes_max
, abs_neutrophils_min, abs_neutrophils_max
, atyps_min, atyps_max
, bands_min, bands_max
, imm_granulocytes_min, imm_granulocytes_max
, metas_min, metas_max
, nrbc_min, nrbc_max
-- coagulation
, d_dimer_min, d_dimer_max
, fibrinogen_min, fibrinogen_max
, thrombin_min, thrombin_max
, inr_min, inr_max
, pt_min, pt_max
, ptt_min, ptt_max
-- enzymes and bilirubin
, alt_min, alt_max
, alp_min, alp_max
, ast_min, ast_max
, amylase_min, amylase_max
, bilirubin_total_min, bilirubin_total_max
, bilirubin_direct_min, bilirubin_direct_max
, bilirubin_indirect_min, bilirubin_indirect_max
, ck_cpk_min, ck_cpk_max
, ck_mb_min, ck_mb_max
, ggt_min, ggt_max
, ld_ldh_min, ld_ldh_max
FROM `physionet-data.mimiciv_icu.icustays` ie
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
;
