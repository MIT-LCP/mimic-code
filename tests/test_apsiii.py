"""Regression tests for APS III worst-PaO2 selection in MIMIC-IV and MIMIC-III."""
from pathlib import Path

import pytest

from mimic_utils.transpile import transpile_query

REPO_ROOT = Path(__file__).resolve().parent.parent
MIMIC_III_SCHEMA_MAP = {"mimiciii_clinical": "mimiciii", "mimiciii_notes": "mimiciii"}


def test_mimic_iv_apsiii_uses_lowest_pao2():
    duckdb = pytest.importorskip("duckdb")
    con = duckdb.connect()
    con.execute(
        "CREATE SCHEMA mimiciv_icu;"
        "CREATE SCHEMA mimiciv_hosp;"
        "CREATE SCHEMA mimiciv_derived;"
    )
    con.execute(
        """
        CREATE TABLE mimiciv_icu.icustays AS
        SELECT 1 AS subject_id, 10 AS hadm_id, 100 AS stay_id,
               TIMESTAMP '2150-01-01 00:00:00' AS intime,
               TIMESTAMP '2150-01-03 00:00:00' AS outtime;
        CREATE TABLE mimiciv_hosp.admissions AS SELECT 10 AS hadm_id;
        CREATE TABLE mimiciv_hosp.patients AS SELECT 1 AS subject_id;
        CREATE TABLE mimiciv_derived.bg AS
        SELECT 10 AS hadm_id, TIMESTAMP '2150-01-01 02:00:00' AS charttime,
               45.0 AS po2, CAST(NULL AS DOUBLE) AS aado2,
               CAST(NULL AS DOUBLE) AS ph, CAST(NULL AS DOUBLE) AS pco2,
               21.0 AS fio2, CAST(NULL AS DOUBLE) AS fio2_chartevents,
               'ART.' AS specimen
        UNION ALL
        SELECT 10, TIMESTAMP '2150-01-01 06:00:00',
               95.0, NULL, NULL, NULL, 21.0, NULL, 'ART.';
        CREATE TABLE mimiciv_derived.ventilation (
            stay_id INT, starttime TIMESTAMP, endtime TIMESTAMP,
            ventilation_status VARCHAR
        );
        CREATE TABLE mimiciv_derived.first_day_urine_output (
            stay_id INT, urineoutput DOUBLE
        );
        CREATE TABLE mimiciv_derived.first_day_lab (
            stay_id INT, hematocrit_min DOUBLE, hematocrit_max DOUBLE,
            wbc_min DOUBLE, wbc_max DOUBLE, creatinine_min DOUBLE,
            creatinine_max DOUBLE, bun_min DOUBLE, bun_max DOUBLE,
            sodium_min DOUBLE, sodium_max DOUBLE, albumin_min DOUBLE,
            albumin_max DOUBLE, bilirubin_total_min DOUBLE,
            bilirubin_total_max DOUBLE, glucose_min DOUBLE, glucose_max DOUBLE
        );
        CREATE TABLE mimiciv_hosp.diagnoses_icd (
            hadm_id INT, icd_version INT, icd_code VARCHAR
        );
        CREATE TABLE mimiciv_derived.first_day_gcs (
            stay_id INT, gcs_min INT, gcs_motor INT, gcs_verbal INT,
            gcs_eyes INT, gcs_unable INT
        );
        CREATE TABLE mimiciv_derived.first_day_vitalsign (
            stay_id INT, heart_rate_min DOUBLE, heart_rate_max DOUBLE,
            mbp_min DOUBLE, mbp_max DOUBLE, temperature_min DOUBLE,
            temperature_max DOUBLE, resp_rate_min DOUBLE, resp_rate_max DOUBLE,
            glucose_min DOUBLE, glucose_max DOUBLE
        );
        """
    )

    bq = (REPO_ROOT / "mimic-iv" / "concepts" / "score" / "apsiii.sql").read_text()
    sql = transpile_query(bq, "bigquery", "duckdb")
    row = con.execute(sql).fetchdf().iloc[0]
    assert row["pao2_aado2_score"] == 15
    assert row["apsiii"] == 15


def test_mimic_iii_apsiii_uses_lowest_pao2():
    duckdb = pytest.importorskip("duckdb")
    con = duckdb.connect()
    con.execute("CREATE SCHEMA mimiciii; CREATE SCHEMA mimiciii_derived;")
    con.execute(
        """
        CREATE TABLE mimiciii.icustays AS
        SELECT 1 AS subject_id, 10 AS hadm_id, 100 AS icustay_id,
               TIMESTAMP '2150-01-01 00:00:00' AS intime,
               TIMESTAMP '2150-01-03 00:00:00' AS outtime;
        CREATE TABLE mimiciii.admissions AS SELECT 10 AS hadm_id;
        CREATE TABLE mimiciii.patients AS SELECT 1 AS subject_id;
        CREATE TABLE mimiciii_derived.blood_gas_first_day_arterial AS
        SELECT 100 AS icustay_id, TIMESTAMP '2150-01-01 02:00:00' AS charttime,
               45.0 AS po2, CAST(NULL AS DOUBLE) AS aado2,
               CAST(NULL AS DOUBLE) AS ph, CAST(NULL AS DOUBLE) AS pco2,
               21.0 AS fio2, CAST(NULL AS DOUBLE) AS fio2_chartevents
        UNION ALL
        SELECT 100, TIMESTAMP '2150-01-01 06:00:00',
               95.0, NULL, NULL, NULL, 21.0, NULL;
        CREATE TABLE mimiciii_derived.ventilation_durations (
            icustay_id INT, starttime TIMESTAMP, endtime TIMESTAMP
        );
        CREATE TABLE mimiciii_derived.ventilation_first_day (
            icustay_id INT, vent INT
        );
        CREATE TABLE mimiciii_derived.urine_output_first_day (
            icustay_id INT, urineoutput DOUBLE
        );
        CREATE TABLE mimiciii_derived.labs_first_day (
            icustay_id INT, hematocrit_min DOUBLE, hematocrit_max DOUBLE,
            wbc_min DOUBLE, wbc_max DOUBLE, creatinine_min DOUBLE,
            creatinine_max DOUBLE, bun_min DOUBLE, bun_max DOUBLE,
            sodium_min DOUBLE, sodium_max DOUBLE, albumin_min DOUBLE,
            albumin_max DOUBLE, bilirubin_min DOUBLE, bilirubin_max DOUBLE,
            glucose_min DOUBLE, glucose_max DOUBLE
        );
        CREATE TABLE mimiciii.diagnoses_icd (
            hadm_id INT, icd9_code VARCHAR
        );
        CREATE TABLE mimiciii_derived.gcs_first_day (
            icustay_id INT, mingcs INT, gcsmotor INT, gcsverbal INT,
            gcseyes INT, endotrachflag INT
        );
        CREATE TABLE mimiciii_derived.vitals_first_day (
            icustay_id INT, heartrate_min DOUBLE, heartrate_max DOUBLE,
            meanbp_min DOUBLE, meanbp_max DOUBLE, tempc_min DOUBLE,
            tempc_max DOUBLE, resprate_min DOUBLE, resprate_max DOUBLE,
            glucose_min DOUBLE, glucose_max DOUBLE
        );
        """
    )

    bq = (
        REPO_ROOT / "mimic-iii" / "concepts" / "severityscores" / "apsiii.sql"
    ).read_text(encoding="utf-8-sig")
    sql = transpile_query(bq, "bigquery", "duckdb", MIMIC_III_SCHEMA_MAP)
    row = con.execute(sql).fetchdf().iloc[0]
    assert row["pao2_aado2_score"] == 15
    assert row["apsiii"] == 15
