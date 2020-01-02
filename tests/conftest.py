import pytest
import psycopg2
from psycopg2 import sql
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT


@pytest.fixture()
def mimic_demo_url():
    return 'https://physionet.org/files/mimiciii-demo/1.4/'


@pytest.fixture()
def mimic_tables():
    return (
        'ADMISSIONS', 'CALLOUT', 'CAREGIVERS', 'CHARTEVENTS', 'CPTEVENTS',
        'D_CPT', 'D_ICD_DIAGNOSES', 'D_ICD_PROCEDURES', 'D_ITEMS', 'D_LABITEMS',
        'DATETIMEEVENTS', 'DIAGNOSES_ICD', 'DRGCODES', 'ICUSTAYS',
        'INPUTEVENTS_CV', 'INPUTEVENTS_MV', 'LABEVENTS', 'MICROBIOLOGYEVENTS',
        'NOTEEVENTS', 'OUTPUTEVENTS', 'PATIENTS', 'PRESCRIPTIONS',
        'PROCEDUREEVENTS_MV', 'PROCEDURES_ICD', 'SERVICES', 'TRANSFERS'
    )


@pytest.fixture()
def mimic_db_params():
    return {
        'user': 'postgres',
        'password': 'postgres',
        'name': 'mimic_test_db',
        'host': 'localhost',
        'schema': 'mimiciii'
    }


@pytest.fixture()
def mimic_schema(mimic_db_params):
    return mimic_db_params['schema']


@pytest.fixture()
def create_mimic_db(mimic_db_params):
    # create the database using postgres/postgres
    con = psycopg2.connect(
        dbname='postgres',
        password='postgres',
        user=mimic_db_params['user'],
        host=mimic_db_params['host']
    )

    con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cur = con.cursor()

    cur.execute(
        sql.SQL("DROP DATABASE IF EXISTS {}").format(
            sql.Identifier(mimic_db_params['name'])
        )
    )
    cur.execute(
        sql.SQL("CREATE DATABASE {}").format(
            sql.Identifier(mimic_db_params['name'])
        )
    )

    cur.close()
    con.close()

    return None


@pytest.fixture(scope="session")
def mimic_demo_path(tmpdir_factory):
    return tmpdir_factory.mktemp('data')


@pytest.fixture()
def mimic_con(mimic_db_params):
    con = psycopg2.connect(
        user=mimic_db_params['user'],
        password=mimic_db_params['password'],
        dbname=mimic_db_params['name'],
        host=mimic_db_params['host']
    )
    con.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    return con
